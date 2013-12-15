%test the accuracy using fast version edit distance

numPixel = 28;
numEle = 150;      %number of examples of each class
      %total example * dimension of image
numLanM = 5;      %number of landmarks for each class


%get data from large testData
load('largeset/lanMatrix.mat');
load('largeset/lanIndex.mat');
load('largeset/newMatrix.mat');
load('largeset/allLanIndex.mat');
load('largeset/testData.mat');
load('largeset/optAutoWeight1.mat');


%FreemanCode Distance,
lanFreeman = cell(size(lanMatrix,1),1);
for i = 1:size(lanMatrix,1),
    imagei = reshape(lanMatrix(i,1:end-1),numPixel,numPixel)';
    temp = freeman(imagei);
    lanFreeman{i,1} = temp.code;
end

trainFreeman = cell(size(testData,1),1);
for i = 1:size(trainFreeman,1),
    imagei = reshape(testData(i,1:end-1),numPixel,numPixel)';
    temp = freeman(imagei);
    trainFreeman{i,1} = temp.code;
end

