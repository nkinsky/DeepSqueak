

[ClusteringData]= CreateClusteringData(handles.data, 1)
load("C:\Users\Russell\OneDrive - UW\Grad School\DeepSqueak Modification Project\DS_Training_Files\Whistle_Selection_Training\IMMS_All_Training_20190112_010000(1).mat")


histogram((Calls.Box(:,3)))

histogram((Calls.Box(:,2)))
histogram((Calls.Box(:,2) + Calls.Box(:,4)))


ClusteringData = {};
clustAssign = [];
xFreq = [];
xTime = [];
stats.Power = [];
stats.DeltaTime = [];
filePath = 0
forClustering = 0
fileName = {0};
j = 1
file.Calls = Calls;


lowerFreq = prctile(file.Calls.Box(:,2), 1);
upperFreq = prctile(file.Calls.Box(:,4) + file.Calls.Box(:,2), 95);

for i = 1:height(file.Calls)
    
    % Skip if not accepted
    if ~file.Calls.Accept(i) || ismember(file.Calls.Type(i),'Noise')
        continue
    end
    
    call = file.Calls(i,:);
    call.RelBox(2) = lowerFreq;
    call.RelBox(4) = upperFreq - lowerFreq;

    [I,wind,noverlap,nfft,rate,box] = CreateSpectrogram(call, .01, .005, .01);
    
    im = mat2gray(flipud(I), prctile(I, [1 99], 'all')); % normalize brightness
    
    if forClustering
        stats = CalculateStats(I,wind,noverlap,nfft,rate,box,data.settings.EntropyThreshold,data.settings.AmplitudeThreshold);
        spectrange = call.Rate / 2000; % get frequency range of spectrogram in KHz
        FreqScale = spectrange / (1 + floor(nfft / 2)); % size of frequency pixels
        TimeScale = (wind - noverlap) / call.Rate; % size of time pixels
        xFreq = FreqScale * (stats.ridgeFreq_smooth) + call.Box(2);
        xTime = stats.ridgeTime * TimeScale;
    end
    
    ClusteringData = [ClusteringData
        [{(im)} % Image
        {call.RelBox(2)} % Lower freq
        {stats.DeltaTime} % Delta time
        {xFreq} % Time points
        {xTime} % Freq points
        {[filePath fileName{j}]} % File path
        {i} % Call ID in file
        {stats.Power}
        {call.RelBox(4)}
        ]'];
    
    clustAssign = [clustAssign; file.Calls.Type(i)];
end


ClusteringData = cell2table(ClusteringData, 'VariableNames', {'Spectrogram', 'MinFreq', 'Duration', 'xFreq', 'xTime', 'Filename', 'callID', 'Power', 'Bandwidth'});





% Find the median call length
maxDuration     = cellfun(@(callSpectrogram) size(callSpectrogram,2), ClusteringData.Spectrogram);
maxDuration     = round(prctile(maxDuration,95));
maxBandwidth    = cellfun(@(callSpectrogram) size(callSpectrogram,1), ClusteringData.Spectrogram);
maxBandwidth    = round(prctile(maxBandwidth,95));

imageSize = [64, 64, 1];
images = zeros([imageSize, size(ClusteringData, 1)]);
for i = 1:size(ClusteringData, 1)
    callDuration = size(ClusteringData.Spectrogram{i}, 2);
    
    padX = maxDuration  - size(ClusteringData.Spectrogram{i}, 2);
    padX = maxDuration  - sqrt(maxDuration ./ callDuration) .* callDuration;

    padY = maxBandwidth - size(ClusteringData.Spectrogram{i}, 1);
    padY = 0;
    padX = 0;
    im = padarray(  ClusteringData.Spectrogram{i}, max(round([padY/2, padX/2]), 1), 'both');
    images(:,:,:,i) = imresize(im, imageSize(1:2));
end
figure; montage(images(:,:,:,1:32))


images = dlarray(single(images), 'SSCB');
[trainInd,valInd] = dividerand(size(ClusteringData, 1), .8, .2);

XTrain  = images(:,:,:,trainInd);
XTest   = images(:,:,:,valInd);




latentDim = 32;
imageSize = size(images,1:3);

encoderLG = layerGraph([
    imageInputLayer(imageSize,'Name','input_encoder','Normalization','none')
    
    convolution2dLayer(3, 16, 'Padding','same', 'Stride', 2, 'Name', 'conv1')
    batchNormalizationLayer('Name', 'bnorm1')
    reluLayer('Name','relu1')
    
    convolution2dLayer(3, 32, 'Padding','same', 'Stride', 2, 'Name', 'conv2')
    batchNormalizationLayer('Name', 'bnorm2')
    reluLayer('Name','relu2')
    
    convolution2dLayer(3, 32, 'Padding','same', 'Stride', 2, 'Name', 'conv3')
    batchNormalizationLayer('Name', 'bnorm3')
    reluLayer('Name','relu3')
    
    convolution2dLayer(3, 64, 'Padding','same', 'Stride', 2, 'Name', 'conv4')
    batchNormalizationLayer('Name', 'bnorm4')
    reluLayer('Name','relu4')
    
    fullyConnectedLayer(2 * latentDim, 'Name', 'fc_encoder')
    ]);

decoderLG = layerGraph([
    imageInputLayer([1 1 latentDim],'Name','i','Normalization','none')
    
    transposedConv2dLayer(4, 64, 'Cropping', 'same', 'Stride', 4, 'Name', 'transpose1')
    batchNormalizationLayer('Name', 'bnorm1')
    reluLayer('Name','relu1')
    transposedConv2dLayer(3, 64, 'Cropping', 'same', 'Stride', 2, 'Name', 'transpose2')
    batchNormalizationLayer('Name', 'bnorm2')
    reluLayer('Name','relu2')
    transposedConv2dLayer(3, 32, 'Cropping', 'same', 'Stride', 2, 'Name', 'transpose3')
    batchNormalizationLayer('Name', 'bnorm3')
    reluLayer('Name','relu3')
    transposedConv2dLayer(3, 32, 'Cropping', 'same', 'Stride', 2, 'Name', 'transpose4')
    batchNormalizationLayer('Name', 'bnorm4')
    reluLayer('Name','relu4')
    transposedConv2dLayer(3, 16, 'Cropping', 'same', 'Stride', 2, 'Name', 'transpose5')
    batchNormalizationLayer('Name', 'bnorm5')
    reluLayer('Name','relu5')
    transposedConv2dLayer(3, 1, 'Cropping', 'same', 'Name', 'transpose6')
    ]);



analyzeNetwork(encoderLG)
analyzeNetwork(decoderLG)



numTrainImages = size(XTrain, 4);
encoderNet = dlnetwork(encoderLG);
decoderNet = dlnetwork(decoderLG);



executionEnvironment = "auto";


numEpochs = 100;
miniBatchSize = 128;
lr = 1e-3;
numIterations = floor(numTrainImages/miniBatchSize);
iteration = 0;

avgGradientsEncoder = [];
avgGradientsSquaredEncoder = [];
avgGradientsDecoder = [];
avgGradientsSquaredDecoder = [];




for epoch = 1:numEpochs
    tic;
    for i = 1:numIterations
        iteration = iteration + 1;
        idx = (i-1)*miniBatchSize+1:i*miniBatchSize;
        XBatch = XTrain(:,:,:,idx);
        XBatch = dlarray(single(XBatch), 'SSCB');
        
        if (executionEnvironment == "auto" && canUseGPU) || executionEnvironment == "gpu"
            XBatch = gpuArray(XBatch);           
        end 
            
        [infGrad, genGrad] = dlfeval(...
            @modelGradients, encoderNet, decoderNet, XBatch);
        
        [decoderNet.Learnables, avgGradientsDecoder, avgGradientsSquaredDecoder] = ...
            adamupdate(decoderNet.Learnables, ...
                genGrad, avgGradientsDecoder, avgGradientsSquaredDecoder, iteration, lr);
        [encoderNet.Learnables, avgGradientsEncoder, avgGradientsSquaredEncoder] = ...
            adamupdate(encoderNet.Learnables, ...
                infGrad, avgGradientsEncoder, avgGradientsSquaredEncoder, iteration, lr);
    end
    elapsedTime = toc;
    
    [z, zMean, zLogvar] = sampling(encoderNet, XTest);
    forward(encoderNet, XTest);
    xPred = sigmoid(forward(decoderNet, z));
    elbo = ELBOloss(XTest, xPred, zMean, zLogvar);
    disp("Epoch : "+epoch+" Test ELBO loss = "+gather(extractdata(elbo))+...
        ". Time taken for epoch = "+ elapsedTime + "s")    
end





[~, zMean, zLogvar] = sampling(encoderNet, images);
zMean = stripdims(zMean)';
zMean = gather(extractdata(zMean));
embed = tsne(zMean,'Verbose',1,'Perplexity',30);


clustAssign = kmeans(zMean, 15, 'Replicates', 20)
clustAssign =  dbscan(D,[],5,'Distance','precomputed')

D = pdist2(double(zMean), double(zMean));

[clustAssign,C]=kmeans_opt(double(zMean),str2num(opt_options{1}),0,str2num(opt_options{2}));







function visualizeLatentSpace(XTest, YTest, encoderNet)
[~, zMean, zLogvar] = sampling(encoderNet, images);

zMean = stripdims(zMean)';
zMean = gather(extractdata(zMean));

zLogvar = stripdims(zLogvar)';
zLogvar = gather(extractdata(zLogvar));

[~,scoreMean] = pca(zMean);
[~,scoreLogvar] = pca(zLogvar);




c = parula(10);
f1 = figure;
figure(f1)
title("Latent space")

ah = subplot(1,2,1);
scatter(scoreMean(:,2),scoreMean(:,1),[],c(double(YTest),:));
ah.YDir = 'reverse';
axis equal
xlabel("Z_m_u(2)")
ylabel("Z_m_u(1)")
cb = colorbar; cb.Ticks = 0:(1/9):1; cb.TickLabels = string(0:9);

ah = subplot(1,2,2);
scatter(scoreLogvar(:,2),scoreLogvar(:,1),[],c(double(YTest),:));
ah.YDir = 'reverse';
xlabel("Z_v_a_r(2)")
ylabel("Z_v_a_r(1)")
cb = colorbar;  cb.Ticks = 0:(1/9):1; cb.TickLabels = string(0:9);
axis equal
end





function generate(decoderNet, latentDim)
randomNoise = dlarray(randn(1,1,latentDim,25),'SSCB');
generatedImage = sigmoid(predict(decoderNet, randomNoise));
generatedImage = extractdata(generatedImage);

f3 = figure;
figure(f3)
imagesc(imtile(generatedImage, "ThumbnailSize", [100,100]))
title("Generated samples of digits")
drawnow
end






