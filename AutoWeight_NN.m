%optimize weight automatically using NN (not SVM)

numPixel = 28;
numEle = 40;      %number of examples of each class
      %total example * dimension of image
numLanM = 5;      %number of landmarks for each class

load('sampleddata1/trainData.mat');
load('sampleddata1/trainIndex.mat');
load('sampleddata1/lanMatrix.mat');
load('sampleddata1/lanIndex.mat');
load('sampleddata1/backupLanMatrix.mat');
load('sampleddata1/backupLanIndex.mat');
load('sampleddata1/newMatrix.mat');
load('sampleddata1/allLanIndex.mat');

%FreemanCode Distance,
lanFreeman = cell(size(lanMatrix,1),1);
for i = 1:size(lanMatrix,1),
    imagei = reshape(lanMatrix(i,1:end-1),numPixel,numPixel)';
    temp = freeman(imagei);
    lanFreeman{i,1} = temp.code;
end

trainFreeman = cell(size(trainData,1),1);
for i = 1:size(trainFreeman,1),
    imagei = reshape(trainData(i,1:end-1),numPixel,numPixel)';
    temp = freeman(imagei);
    trainFreeman{i,1} = temp.code;
end

%compute kernel matrix

iteration = 50;
accuracyArray = zeros(1,iteration);
maxAccuracy = 0.0;


weightMatrix = [0.00,6.31,7.22,8.61,8.61,9.71,7.14,6.82,3.38;
                6.28,0.00,6.09,9.27,15,8.58,8.17,8.17,3.18;               
                7.14,6.20,0.00,6.77,7.39,9.34,8.24,8.24,3.22;
                15,8.42,6.48,0.00,6.34,7.32,7.32,15,2.67;
                9.69,9.69,7.75,6.80,0.00,7.05,7.90,9.69,3.58;
                7.65,8.57,9.26,15,6.43,0.00,6.27,8.16,3.04;
                7.14,9.34,8.65,8.65,8.24,5.76,0.00,6.70,3.34;
                6.16,7.37,7.77,15,15,8.47,5.83,0.00,2.78;
                3.69,3.77,3.67,4.18,3.52,3.66,3.88,4.18,15];


%load('sampleddata1/optAutoWeight1.mat');
%weightMatrix = optimalWeight;
optimalWeight = zeros(9,9);
threshold = inf;

for m = 1:iteration,
    error = 0;
    information = {};
    %numExampleMatrix is used to count the number of cheapest operations
    %contributing to converting the misclassified example to landmarks
    
   
    for i = 1:size(trainFreeman,1),
       distance_Array = zeros(size(lanFreeman,1),3);
       for j = 1:size(lanFreeman,1),
            d = EditDistanceWeight(trainFreeman{i,1},lanFreeman{j,1},weightMatrix,threshold);
            distance_Array(j,1) = d;
            distance_Array(j,2) = lanMatrix(j,end);
            distance_Array(j,3) = j;
       end
       sorted_distance = sortrows(distance_Array,1);
       top_5 = sorted_distance(1:5,:);
       %build a score table for each class
       score_Table = zeros(10,2);
       for p = 1:10,
           score_Table(p,1) = p-1;
       end
       for p = 1:5,
           score_Table(top_5(p,2)+1,2) = score_Table(top_5(p,2)+1,2) + 1;
       end
       
       %predict the example according to the top 5 landmarks
       temp_score = sortrows(score_Table,-2);
       predict = temp_score(1,1);
       if(predict~=trainData(i,end)),
           error = error + 1;
           field1 = 'true_label';
            value1 = trainData(i,end);
           field2 = 'predicted_label';
            value2 = predict;
            field3 = 'top_landmark';
            value3 = lanMatrix(distance_Array(1,3),1:end-1);
            field4 = 'index_top_landmark';
            value4 = sorted_distance(1,3);
            field5 = 'index_example';
            value5 = i;
             s = struct(field1,value1,field2,value2,field3,value3,field4,value4,field5,...
                 value5);            
            information{size(information,1)+1,1} = s;
       end
    end
    percentage = error/size(trainFreeman,1);
    accuracy = 1-percentage;
    accuracyArray(m) = accuracy;
    if(accuracy>maxAccuracy),
        maxAccuracy = accuracy;
        optimalWeight = weightMatrix;
    end
        
    %adjust the weight matrix for all misclassified examples together 
    numExampleMatrix = zeros(size(weightMatrix,1),size(weightMatrix,2)); 
    for k = 1:size(information,1),
        index_exam = information{k,1}.index_example;
        index_landmark = information{k,1}.index_top_landmark;
        incorrSequence = findPathWeight(trainFreeman{index_exam,1},lanFreeman{index_landmark,1},weightMatrix);
        incorrSequence = sortrows(incorrSequence,3);
        numCount = 6;
        currentCount = 0;
        for i = 1:size(incorrSequence,1),
                if(currentCount>numCount),
                    break;
                end
                if(incorrSequence(i,3)==0),
                    continue;
                end
                row = incorrSequence(i,1);
                column = incorrSequence(i,2);
                numExampleMatrix(row,column) = numExampleMatrix(row,column) + 1;  
                currentCount = currentCount + 1;
        end      
    end
    
    [B,IX] = sort(numExampleMatrix(:),'descend');
    [subRow,subColumn] = ind2sub(size(numExampleMatrix),IX(1));
    weightMatrix(subRow,subColumn) = weightMatrix(subRow,subColumn) + 2;
    
    disp('iteration finish');
end

   

    




