function create_training_images_Callback(hObject, eventdata, handles)
% hObject    handle to create_training_images (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Select the files to make images from
[trainingdata, trainingpath] = uigetfile([char(handles.data.settings.detectionfolder) '/*.mat'],'Select Detection File for Training ','MultiSelect', 'on');
if isnumeric(trainingdata); return; end
trainingdata = cellstr(trainingdata);

% Get training settings
prompt = {'Window Length (s)','Overlap (%)','NFFT (s)','Bout Length (s) [Requires Single Files & Audio]',...
    'Number of augmented duplicates'};
dlg_title = 'Spectrogram Settings';
num_lines=[1 40]; options.Resize='off'; options.windStyle='modal'; options.Interpreter='tex';
spectSettings = str2double(inputdlg(prompt,dlg_title,num_lines,{'0.0032','50','0.0022','1','1'},options));
if isempty(spectSettings); return; end

wind = spectSettings(1);
noverlap = spectSettings(2) * spectSettings(1) / 100;
nfft = spectSettings(3);
bout = spectSettings(4);
repeats = spectSettings(5)+1;
AmplitudeRange = [-.7, .8];
StretchRange = [0.75, 1.25];


h = waitbar(0,'Initializing');

for k = 1:length(trainingdata)
    TTable = table({},{},'VariableNames',{'imageFilename','USV'});
    
    % Load the detection and audio files
    audioReader = squeakData();
    [Calls, audioReader.audiodata] = loadCallfile([trainingpath trainingdata{k}],handles);
    
    % Make a folder for the training images
    [~, filename] = fileparts(trainingdata{k});
    fname = fullfile(handles.data.squeakfolder,'Training','Images',filename);
    mkdir(fname);
    
    % Remove Rejects
    Calls = Calls(Calls.Accept == 1, :);
    
    % Find max call frequency for cutoff
    % freqCutoff = max(sum(Calls.Box(:,[2,4]), 2));
    freqCutoff = audioReader.audiodata.SampleRate / 2;
    
    %% Calculate Groups of Calls
    % Calculate the distance between the end of each box and the
    % beginning of the next
    Distance = pdist2(Calls.Box(:, 1), Calls.Box(:, 1) + Calls.Box(:, 3));
    % Remove calls further apart than the bin size
    Distance(Distance > bout) = 0;
    % Get the indices of the calls by bout number by using the connected
    % components of the graph
    G = graph(Distance,'lower');
    bins = conncomp(G);
    
    for bin = 1:length(unique(bins))
        BoutCalls = Calls(bins == bin, :);
        
        StartTime = max(min(BoutCalls.Box(:,1)), 0);
        FinishTime = max(BoutCalls.Box(:,1) + BoutCalls.Box(:,3));
        StartTime = StartTime - mean(BoutCalls.Box(:,3));
        FinishTime = FinishTime + mean(BoutCalls.Box(:,3));

        
        %% Read Audio
        audio = audioReader.AudioSamples(StartTime, FinishTime);
        
        % Subtract the start of the bout from the box times
        BoutCalls.Box(:,1) = BoutCalls.Box(:,1) - StartTime;
        
        for replicatenumber = 1:repeats
            IMname = sprintf('%g_%g.png', bin, replicatenumber);
            [~,box] = CreateTrainingData(...
                audio,...
                audioReader.audiodata.SampleRate,...
                BoutCalls,...
                wind,noverlap,nfft,...
                freqCutoff,...
                fullfile(fname,IMname),...
                AmplitudeRange,...
                replicatenumber,...
                StretchRange);
            TTable = [TTable;{fullfile('Training','Images',filename,IMname), box}];
            
        end
        waitbar(bin/length(unique(bins)), h, sprintf('Processing File %g of %g', k, length(trainingdata)));        
        
    end
    save(fullfile(handles.data.squeakfolder,'Training',[filename '.mat']),'TTable','wind','noverlap','nfft');
    disp(['Created ' num2str(height(TTable)) ' Training Images']);
end
close(h)
end


% Create training images and boxes
function [im, box] = CreateTrainingData(audio,rate,Calls,wind,noverlap,nfft,freqCutoff,filename,AmplitudeRange,replicatenumber,StretchRange)

% Augment by adjusting the gain
% The first training image should not be augmented
if replicatenumber > 1
    AmplitudeFactor = range(AmplitudeRange).*rand() + AmplitudeRange(1);
    StretchFactor = range(StretchRange).*rand() + StretchRange(1);
else
    AmplitudeFactor = 0;
    StretchFactor = 1;
end

% Make the spectrogram
[s, fr, ti, p] = spectrogram(audio(:,1),...
    round(rate * wind*StretchFactor),...
    round(rate * noverlap*StretchFactor),...
    round(rate * nfft*StretchFactor),...
    rate,...
    'yaxis');

im = log10(p);
im = (im - mean(im, 'all')) * std(im, [],'all');
% hmatch = normpdf(linspace(0,1,1000),0,.2) + normpdf(linspace(0,1,1000),.8,.2)*.1; 
% clim = prctile(im,[30, 99],'all')

im = rescale(im + AmplitudeFactor * im.^3 ./ (im.^2+2), 'InputMin',-1 ,'InputMax', 5);

% figure
% histogram(im + AmplitudeFactor * im.^3, 0:.01:1)
% imshow(im)
% x = linspace(-5,5,100)
% plot(x,  x + .5*x.^3 ./ (x.^2 + 1))



maxfreq = find(fr < freqCutoff,1, 'last');
im = im(1:maxfreq,:);
fr = fr(1:maxfreq,:);
im = flipud(im);



% med = median(im(:))*AmplitudeFactor;
% im = mat2gray(im,[med*.1 med*35]);
% im2 = mat2gray(s,[med*.5 med*25]);
% im3 = mat2gray(s,[med med*15]);
% im=(cat(3,im,im2,im3));


% Find the box within the spectrogram
x1 = axes2pix(length(ti), ti, Calls.Box(:,1));
x2 = axes2pix(length(ti), ti, Calls.Box(:,3));
y1 = axes2pix(length(fr), fr./1000, Calls.Box(:,2));
y2 = axes2pix(length(fr), fr./1000, Calls.Box(:,4));


box = round([x1, length(fr)-y1-y2, x2, y2]);
box = box(Calls.Accept == 1, :);


while size(im,2)<25
    box = [box;[box(:,1)+size(im,2) box(:,2:4)]];
    im = [im im];
end

% im = insertShape(im, 'rectangle', box);
% figure; imagesc(insertShape(im, 'rectangle', box))
imwrite(im, filename, 'BitDepth', 8);
end
