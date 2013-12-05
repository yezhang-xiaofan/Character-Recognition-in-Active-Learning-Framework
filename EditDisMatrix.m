%compute the matrix of edit distance
numEle = 5;
numLanM = 5;
numPixel = 28;
for j = 0:9
    str = sprintf('%d',j);
    tempStr = strcat('data',str,'.txt');
    fid = fopen(tempStr,'r');
    subMatrix = zeros(numEle+numLanM,numPixel*numPixel+1);
    for i = 1:numEle+numLanM,
        temp = fread(fid,[1,numPixel*numPixel],'uchar');
        temp = im2bw(temp);
        subMatrix(i,1:end-1) = temp';
        subMatrix(i,end) = j;
    end   
    %randomly choose some landmarks from subMatrix
    %landIndex = randperm(numEle+numLanM,numLanM);
    %subLanMatrix = zeros(numLanM,numPixel*numPixel+1);
    %lanMatrix(j*numLanM+1:j*numLanM+numLanM,:) = subMatrix(landIndex,:);
    %subMatrix(landIndex,:) = [];
    matrix(j*(numEle+numLanM)+1:j*(numEle+numLanM)+numEle+numLanM,:) = subMatrix;   
end
newMatrix = matrix;
matrix = zeros(10,10);
code = cell(1,10);
for k = 1:7,
    for i = 0:9,
        imagei = reshape(newMatrix((i*(numEle+numLanM)+k),1:end-1),28,28)';
        imagei1 = reshape(newMatrix((i*(numEle+numLanM)+k+2),1:end-1),28,28)';
        freeman1 = freeman(imagei);
        freeman2 = freeman(imagei1);
        matrix(i+1,i+1) = matrix(i+1,i+1) + EditDistance(freeman1.code,freeman2.code);
        for j = 0:9
            if(j==i),
                continue;
            end
            imagej = reshape(newMatrix((j*(numEle+numLanM)+k+3),1:end-1),28,28)';
            freeman3 = freeman(imagej);
            matrix(i+1,j+1) = matrix(i+1,j+1) + EditDistance(freeman1.code,freeman3.code);
        end
    end
end
matrix = matrix/k;
disp('finish');

%{
for i = 1:10,
    for j = 1:10,
        tempi = code{1,i};
        tempj = code{1,j};
        matrix(i,j) = EditDistance(tempi,tempj);
    end
end
disp('finish');
%}