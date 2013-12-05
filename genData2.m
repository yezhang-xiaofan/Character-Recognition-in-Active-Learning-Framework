%extract dataset

numPixel = 28;
numEle = 150;      %number of examples of each class
      %total example * dimension of image
load('wholedata.mat');
matrix = zeros(numEle*10,numPixel*numPixel+1);


for j = 0:9,
    subMatrix = zeros(numEle,numPixel*numPixel+1);
    for i = 1:numEle,
        temp = newMatrix(j*1000+i+45,1:end-1);
        temp = im2bw(temp);
        %temp = reshape(temp,numPixel,numPixel);
        %temp = temp';
        subMatrix(i,1:end-1) = temp(:);
        subMatrix(i,end) = j;
    end
    matrix(j*numEle+1:j*numEle+numEle,:) = subMatrix;
end


testData = matrix;
save('largeset/testdata','testData');







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
