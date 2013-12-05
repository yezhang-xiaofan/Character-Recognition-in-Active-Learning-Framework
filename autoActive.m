% use the optimal weight obtained by automatically adjusting, then use the
% user feedback to adjust 
%edit distance kernel
numPixel = 28;
numEle = 40;      %number of example of each class
      %total example * dimension of image
numLanM = 5;      %number of landmarks for each class

load('trainData.mat');
load('trainIndex.mat');
load('lanMatrix.mat');
load('lanIndex.mat');
load('backupLanMatrix.mat');
load('backupLanIndex.mat');
load('newMatrix.mat');

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

load('autoOptimalWeight');
weightMatrix = optimalWeight;

iteration = 15;
accuracyArray = zeros(1,iteration);
maxAccuracy = 0;
optimalWeight = zeros(9,9);

for m = 1:iteration,
    tempWeight = weightMatrix;
    sigma = (2.36)^2;
    kernelMatrix = zeros(numEle*10,numLanM*10+1);
    for i = 1:size(trainFreeman,1),
       for j = 1:size(lanFreeman,1),
            d = EditDistanceWeight(trainFreeman{i,1},lanFreeman{j,1},weightMatrix);
            kernelMatrix(i,j) = exp(-d^2/sigma);            
       end
       kernelMatrix(i,end) = trainData(i,end);
    end
    
    training_label_vector = kernelMatrix(:,end);
    training_instance_matrix = kernelMatrix(:,1:end-1);
    %normalize the matrix based on features
    %training_instance_matrix = normc(training_instance_matrix);
    training_instance_matrix = normr(training_instance_matrix);
    training_instance_matrix = sparse(training_instance_matrix);

    %L1-Loss SVM 
    model = train(training_label_vector,training_instance_matrix,'-s 1 -c 1');
    [predict_label,accuracy,dec_values] = predict(training_label_vector,training_instance_matrix,model);
    accuracyArray(m) = accuracy(1);
    if(accuracy(1)>maxAccuracy),
        maxAccuracy = accuracy(1);
        optimalWeight = weightMatrix;
    end
    compare = [predict_label,training_label_vector];
    weights = model.w;
    labelSet = model.Label;
    numMis = sum((predict_label - training_label_vector)~=0);
    information = cell(numMis,1);
    j = 1;
    for i = 1:numEle*10,
        if(predict_label(i)~=training_label_vector(i)),

            field1 = 'true_label';
            value1 = training_label_vector(i);

            field2 = 'predicted_label';
            value2 = predict_label(i);

            field3 = 'feature_values';
            value3 = training_instance_matrix(i,:);

            indexcorrect = find(labelSet==value1,1);
            indexincorrect = find(labelSet==value2,1);

            field4 = 'weighted_value_for_incorrected_class';
            value4 = weights(indexincorrect,:).*training_instance_matrix(i,:);

            field5 = 'weighted_value_for_correct_class';
            value5 = weights(indexcorrect,:).*training_instance_matrix(i,:);

            field6 = 'top3_landmarks_for_incorrect_class_with_datapoint';
            %sort landmark based on weight*feature
            [sortedValues,sortIndex] = sort(value4(:),'descend');
            maxIndex = sortIndex(1:3);
            landmark1 = lanMatrix(maxIndex(1),:);
            landmark2 = lanMatrix(maxIndex(2),:);
            landmark3 = lanMatrix(maxIndex(3),:);
            value6 = [landmark1;landmark2;landmark3;trainData(i,:)];
            
            field15 = 'top_landmark_index_incorrect';
            value15 = sortIndex;

            field13 = 'image_top3_landmarks_incorrect_with_datapoint';
            value13 = [newMatrix(lanIndex(maxIndex),:);newMatrix(trainIndex(i),:)];

            field8 = 'top3_landmarks_for_correct_class_with_datapoint';
            [sortedValues,sortIndex] = sort(value5(:),'descend');
            maxIndex = sortIndex(1:3);
            landmark1 = lanMatrix(maxIndex(1),:);
            landmark2 = lanMatrix(maxIndex(2),:);
            landmark3 = lanMatrix(maxIndex(3),:);
            value8 = [landmark1;landmark2;landmark3;trainData(i,:)];
           
            field12 = 'image_top3_landmarks_correct_with_datapoint';
            value12 = [newMatrix(lanIndex(maxIndex),:);newMatrix(trainIndex(i),:)];

            field14 = 'top_landmark_index_correct';
            value14 = sortIndex;
            s = struct(field1,value1,field2,value2,field3,value3,field4,value4,field5,value5,field6,value6,field8,value8,...
                field12,value12,field13,value13,field14,value14,field15,value15);
            information{j} = s;
            j = j+1;            
                       
        end
    end
    disp('iteration finish');
end
disp('finish');






