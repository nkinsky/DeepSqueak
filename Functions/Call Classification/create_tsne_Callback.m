function create_tsne_Callback(hObject, eventdata, handles)
% Creates a 2-dimensional t-sne image of calls.


padding = 1000; % Pad the temp image by this amount, so that calls near the border still fit.
blackLevel = 10; % Subtract this value from each call image to make a nicer picture.

% Select embedding type
embeddingType = questdlg('Embed with UMAP or t-SNE?', 'Embedding Method', 't-SNE' , 'UMAP', 't-SNE');
if isempty(embeddingType); return; end
if strcmp(embeddingType, 'UMAP')
    if ~exist('run_umap.m', 'file')
        msgbox('Please download UMAP and add it to MATLAB''s path and try again')
        web('   https://www.mathworks.com/matlabcentral/fileexchange/71902-uniform-manifold-approximation-and-projection-umap');
        return
    end
end

% Get the clustering parameters, prepare data as if performing k-means
clusterParameters= inputdlg({'Shape weight','Frequency weight','Duration weight','Images height (pixels)','Image width (pixels)','Perplexity','Max number of calls to plot (set to 0 to plot everything)'},'Choose cluster parameters:',1,{'1','1','1','6000','6000','30','2000'});
if isempty(clusterParameters); return; end

% Choose to assign colors by the call classification or by pitch.
colorType = questdlg({'Color the calls by frequecy (pitch), or by cluster identity?','If coloring by cluster, you may not use pre-extracted contours'}, 'Choose Color', 'Frequency' , 'Cluster', 'Frequency');
if isempty(colorType); return; end

slope_weight = str2double(clusterParameters{1});
freq_weight = str2double(clusterParameters{2});
duration_weight = str2double(clusterParameters{3});
imsize = str2double(clusterParameters(4:5))';
perplexity = str2double(clusterParameters{6});
NumberOfCalls = str2double(clusterParameters{7});

% Get the data
[ClusteringData, clustAssign] = CreateClusteringData(handles, 1);

if NumberOfCalls == 0
    NumberOfCalls = size(ClusteringData,1);
end
NumberOfCalls = min(size(ClusteringData,1), NumberOfCalls);



%% Extract features
ReshapedX   = cell2mat(cellfun(@(x) imresize(x',[1 9]) ,ClusteringData.xFreq,'UniformOutput',0));
slope       = diff(ReshapedX,1,2);
slope       = zscore(slope);
freq        = cell2mat(cellfun(@(x) imresize(x',[1 8]) ,ClusteringData.xFreq,'UniformOutput',0));
freq        = zscore(freq);
duration    = repmat(ClusteringData.Duration,[1 8]);
duration    = zscore(duration);


data = [
    freq     .*  freq_weight,...
    slope    .*  slope_weight,...
    duration .*  duration_weight,...
    ];

%% Get parameters


% Calculate embeddings
rng default;

switch embeddingType
    case 't-SNE'
        embed = tsne(data,'Verbose',1,'Perplexity',perplexity);
    case 'UMAP'
        embed = run_umap(data);
end

embed = (embed - min(embed)) ./ (max(embed)-min(embed));

ClusteringData.embedY = 1-embed(:,2); % flip Y coordinates so the images looks like the UMAP figure
ClusteringData.embedX = embed(:,1);

switch colorType
    case 'Frequency'
        minfreq = floor(min(ClusteringData.MinFreq))-1; % Find the min frequency
        maxfreq = ceil(max(ClusteringData.MinFreq + ClusteringData.Bandwidth)); % Find the max frequency
        ColorData = jet(maxfreq - minfreq);
        ColorData = HSLuv_to_RGB(maxfreq - minfreq, 'H',  [270 0], 'S', 100, 'L', 75); % Make a color map for each category
        ColorData = reshape(ColorData,size(ColorData,1),1,size(ColorData,2));
    case 'Cluster'
        [clustAssignID, cName] = findgroups(clustAssign); % Convert categories into numbers
        ClusteringData.Cluster = clustAssignID; % Append the category number to clustering data
        
        % make it so that adjacent clusters are generally different colors.
        % it turns out that this isn't trivial, so try 200 different color
        % orders and use the best one.
        clusterCentroids = splitapply(@mean, [ClusteringData.embedY, ClusteringData.embedX], clustAssignID);
        clusterCentroids = pdist2(clusterCentroids, clusterCentroids);
        hueAngle = [
            sin(linspace(0,2*pi, length(cName)))
            cos(linspace(0,2*pi, length(cName)))]';
        hueDistance = pdist2(hueAngle, hueAngle, 'cosine');
        colorSeperation = zeros(200,1);
        colorOrders = zeros(200,length(cName));
        for i = 1:200
            colorOrders(i,:) = randperm(length(cName)); % Randomize the order of the colors
            colorSeperation(i) = sum((1-clusterCentroids).* hueDistance(colorOrders(i,:),colorOrders(i,:)), 'all');
        end
        [~, idx] = max(colorSeperation)
        colorOrder = colorOrders(idx,:)

        hueRange = [0 360-360/length(cName)];
        cMap = HSLuv_to_RGB(length(cName), 'H', hueRange, 'S', 100, 'L', 75); % Make a color map for each category
        cMap = cMap(colorOrder,:);
        figure('Color','w') % Display the colors
        h = image(reshape(cMap,[],1,3));
        yticks(h.Parent,1:length(cName))
        yticklabels(h.Parent, cellstr(cName))
end


%% Create the image
im = zeros([imsize+padding*2,3],'uint8');

% Only plot the X number of calls
calls2plot = randsample(size(ClusteringData, 1), NumberOfCalls, false);

for i = calls2plot'
    call = ClusteringData(i, :);
    % Get x and y coordinates to place with image
    iy = imsize(1) * call.embedY;
    iy = iy:iy + size(call.Spectrogram{:},1) - 1;
    iy = round(iy - mean(size(call.Spectrogram{:},1))) + padding;
    ix = imsize(2) * call.embedX;
    ix = ix:ix + size(call.Spectrogram{:},2) - 1;
    ix = round(ix - mean(size(call.Spectrogram{:},2))) + padding;
    
    % Either use the call pitch or the cluster id to apply a color mask
    switch colorType
        case 'Frequency'
            % High freq to low freq
            freqdata = round(linspace(call.MinFreq + call.Bandwidth, call.MinFreq, size(call.Spectrogram{:},1)));
            colorMask = ColorData(freqdata-minfreq,:,:);
        case 'Cluster'
            colorMask = reshape(cMap(call.Cluster,:),1,1,3);
    end
    % i{1} is the spectrogram
    im(iy,ix,:) = max(im(iy,ix,:),uint8(single(call.Spectrogram{:}) .* colorMask - blackLevel));
    
end



% Crop the image at the first and last non-empty pixel
[y1,~] = find(max(max(im,[],3),[],2),1,'first');
[y2,~] = find(max(max(im,[],3),[],2),1,'last');

[~,x1] = find(max(max(im,[],3),[],1),1,'first');
[~,x2] = find(max(max(im,[],3),[],1),1,'last');

[fname,fpath] = uiputfile('embeddings.jpg','Save image');
imwrite(im2uint8(im(y1:y2,x1:x2,:)),fullfile(fpath,fname))