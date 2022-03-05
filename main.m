clear; clc; close all
%% Parameters Initialization
vid = VideoReader('cam4.mkv'); 
numTrainingFrames = 600;   %Number of frames used to creat Gaussian models
sigma = 20;                %Initial variance of Gaussian distributions
k = 4;                     %Number of Gaussians per pixel
alpha = 0.01;              %Training rate coeffecient
kp = 1;                    %Tolerance\sensitivity from sigma
thresh = 0.4;              %Thresh value to label distributions

%% Variables Initialization
frameZise = [ceil((vid.Height)/5) round((vid.Width)/5)];
muMat = zeros(frameZise(1), frameZise(2), k);       %Mean(mu) matrix 
sigmaMat = ones(frameZise(1), frameZise(2), k);     %Variance matrix
weightswMat = zeros(frameZise(1), frameZise(2), k); %weights(w) matrix
evidnceToSigmaMat = zeros(frameZise(1), frameZise(2), k);
%outMat is the matrix that will save every backgroundmodel after every
%frame to print it continously at the end, since the computation takes time
outMat = zeros(frameZise(1),frameZise(2),numTrainingFrames); 
binary = zeros(frameZise(1),frameZise(2),numTrainingFrames);

t = 1;
%The following 4 lines are there to initialize the parameters for k = 1
muMat(:,:,t) = rgb2gray(imresize(readFrame(vid),0.2));
outMat(:,:,t) = muMat(:,:,1);
sigmaMat(:,:,t) = sigma;
weightswMat(:,:,t) = 1;

%The following while loop to go through frames as long as there is an input
while hasFrame(vid)
    %Read and process every frame
    frame = double(rgb2gray(imresize(readFrame(vid),0.2)));
    %Creat segmentationMat that will hold the binary mask of the image
    segmentationMat = zeros(frameZise(1),frameZise(2));
    if t == numTrainingFrames
        break
    end
    t = t + 1;
    for i = 1:frameZise(1) % To go through all rows
        for j = 1:frameZise(2) % To go through all columns
            X = frame(i,j);
            evidenceToSigma = weightswMat(i,j,:)./sigmaMat(i,j,:);
            [BackgroundIndices, ForgroundIndices] = ArgMinimum(evidenceToSigma, ...
                weightswMat(i,j,:), thresh);
            matchMat = [];
            matchMatIndex = [];
            for kd = 1:k % To go through  all distributions per pixel
                dif = abs(X - muMat(i,j,kd));        
                if dif <= kp * sigmaMat(i,j,kd) %Check pixel for match
                    matchMat = cat(1,matchMat,dif);
                    matchMatIndex = cat(1,matchMatIndex,kd);
                    %Update the distribution parameters
                    weightswMat(i,j,kd) = (1 - alpha) * weightswMat(i,j,kd)...
                        + alpha * (1);
                    rho = alpha * Normal(X, muMat(i,j,kd),...
                        sigmaMat(i,j,kd) );
                    muMat(i,j,kd) = (1 - rho) * muMat(i,j,kd) + rho * X;
                    variance = (1 - rho) * (sigmaMat(i,j,kd)^2) + ... 
                        rho * (X - muMat(i,j,kd) )^2;
                    sigmaMat(i,j,kd) = sqrt(variance);
                    
                    %segmentationMat is a black image, so we need to
                    %specify foreground pixels to get the binary mask
                    if ismember(kd,ForgroundIndices)
                        segmentationMat(i,j) = 1;
                    end 
                else %If pixel didnt match any distribution
                    weightswMat(i,j,kd) = (1 - alpha) * weightswMat(i,j,kd);
                end
            end
            if isempty(matchMat) %Check if no match at all occurred
                zeroIndex = find(~weightswMat(i,j,:)); %Search for zeros
                %Obtain the ratio weights/sigma
                evidnceToSigmaMat(i,j,:) = weightswMat(i,j,:)./sigmaMat(i,j,:);
                if isempty(zeroIndex) %if there is no 0 values
                    %obtain the soreted indices
                    [B,I] = sort(evidnceToSigmaMat(i,j,:));
                    %Replace the parameters of the least distribution
                    muMat(i,j,I(1)) = X;
                    [B1,I1] = sort(weightswMat(i,j,:));
                    % Initialize the new weights to be higher than the
                    % replaced distribution
                    weightswMat(i,j,I(1)) = 1.3 * weightswMat(i,j,I1(1));
                    sigmaMat(i,j,I(1)) = 2*sigma; %assign higher variance
                else %if there is a 0, replace it instead.
                    muMat(i,j,zeroIndex(1)) = X;
                    [B1,I1] = sort(weightswMat(i,j,:));
                    weightswMat(i,j,zeroIndex(1)) = 1.3 * weightswMat(i,j,I1(1));
                    sigmaMat(i,j,zeroIndex(1)) = 2*sigma;
                end
            end
            %Normalizee the weights
            weightswMat(i,j,:) = weightswMat(i,j,:)./sum(weightswMat(i,j,:));
            
            %The following 3 lines are to obtain the background model after 
            % each frame and save it to outMat. For simplicity, we take the 
            % mean of the highest distribution only.
            evidnceToSigmaMat(i,j,:) = weightswMat(i,j,:)./sigmaMat(i,j,:);
            [A,outI] = sort(evidnceToSigmaMat(i,j,:),'descend');
            outMat(i,j,t) = muMat(i,j,outI(1));
        end
    end
    % Show the binary mask
    binary(:,:,t) = mat2gray(segmentationMat(:,:));
    imshow(binary(:,:,t));
end

%To see the background model while getting updated continuously.
for i = 1:t
    imshow(mat2gray(outMat(:,:,i)));
end