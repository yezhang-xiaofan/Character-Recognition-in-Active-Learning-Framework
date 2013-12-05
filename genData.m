%randomly generate training data and landmarks 

numPixel = 28;
numEle = 40;      %number of examples of each class
      %total example * dimension of image
numLanM = 5;      %number of landmarks for each class

matrix = zeros((numEle+5*numLanM)*10,numPixel*numPixel+1);
lanMatrix = zeros(numLanM*10,numPixel*numPixel+1);    %landmark matrix

%read the data and store in matrix
for j = 0:9
    str = sprintf('%d',j);
    tempStr = strcat('data',str,'.txt');
    fid = fopen(tempStr,'r');
    subMatrix = zeros(numEle+5*numLanM,numPixel*numPixel+1);
    for i = 1:numEle+5*numLanM,
        temp = fread(fid,[1,numPixel*numPixel],'uchar');
        temp = im2bw(temp);
        subMatrix(i,1:end-1) = temp';
        subMatrix(i,end) = j;
    end   
    matrix(j*(numEle+5*numLanM)+1:j*(numEle+5*numLanM)+numEle+5*numLanM,:) = subMatrix;
end
newMatrix = matrix;
save('newMatrix','newMatrix');
%Randomly pick some landmarks from each class
trainData = zeros(10*(numEle),numPixel*numPixel+1);
backupLanMatrix = zeros(10*4*numLanM,numPixel*numPixel+1);
%store the index for the original dataset
trainIndex = zeros(10*(numEle),1);
allLanIndex = zeros(10*(5*numLanM),1);

for i = 1:10,
    index = randperm((5*numLanM+numEle));
    index = index + (i-1)*(numEle+5*numLanM);
    %lanIndex = index(1:numLanM);
    %trainIndex = index(numLanM+1:end);
    allLanIndex((i-1)*(5*numLanM)+1:(i-1)*(5*numLanM)+5*numLanM) = index(1:5*numLanM);
    %lanMatrix((i-1)*(numLanM)+1:(i-1)*(numLanM)+numLanM,end) = newMatrix(lanIndex,end);
    trainIndex((i-1)*(numEle)+1:(i-1)*(numEle)+numEle) = index(5*numLanM+1:end);
    %trainData((i-1)*(numEle)+1:(i-1)*(numEle)+numEle,end) = newMatrix(trainIndex,end);
end
trainData = newMatrix(trainIndex,:);
save('allLanIndex','allLanIndex');
save('trainData','trainData');
save('trainIndex','trainIndex');
save('allLanIndex','allLanIndex');

%choose some landmarks as part of training and others as back-ups. 
lanIndex = zeros(10*numLanM,1);
backupLanIndex = zeros(10*4*numLanM,1);
for i = 1:10,
    index = 1:5*numLanM;
    index = index + (i-1)*(5*numLanM);
    lanIndex((i-1)*numLanM+1:(i-1)*numLanM+numLanM) = allLanIndex(index(1:numLanM));
    backupLanIndex((i-1)*4*numLanM+1:(i-1)*4*numLanM+4*numLanM) = allLanIndex(index(numLanM+1:end));
end
    
lanMatrix = newMatrix(lanIndex,:);
save('lanMatrix','lanMatrix');
save('lanIndex','lanIndex');

backupLanMatrix = newMatrix(backupLanIndex,:);
save('backupLanMatrix','backupLanMatrix');
save('backupLanIndex','backupLanIndex');
