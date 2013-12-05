%automatically change the weight using the optimal weight matrix obtained
%from interation 
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

%compute kernel matrix
%{
weightMatrix = [0.00,6.31,7.22,8.61,8.61,9.71,7.14,6.82,3.38;
                6.28,0.00,6.09,9.27,15,8.58,8.17,8.17,3.18;               
                7.14,6.20,0.00,6.77,7.39,9.34,8.24,8.24,3.22;
                15,8.42,6.48,0.00,6.34,7.32,7.32,15,2.67;
                9.69,9.69,7.75,6.80,0.00,7.05,7.90,9.69,3.58;
                7.65,8.57,9.26,15,6.43,0.00,6.27,8.16,3.04;
                7.14,9.34,8.65,8.65,8.24,5.76,0.00,6.70,3.34;
                6.16,7.37,7.77,15,15,8.47,5.83,0.00,2.78;
                3.69,3.77,3.67,4.18,3.52,3.66,3.88,4.18,15];
%}
load('activeOptWeight.mat');
weightMatrix = optimalWeight;
iteration = 50;
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
            
            field7 = 'index_top3_landmarks_for_incorrect_class';
            value7 = maxIndex;
            
            field9 = 'index_example';
            value9 = i;
            
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
            
            field10 = 'index_top3_landmarks_for_correct_class';
            value10 = maxIndex;
           
            field12 = 'image_top3_landmarks_correct_with_datapoint';
            value12 = [newMatrix(lanIndex(maxIndex),:);newMatrix(trainIndex(i),:)];

            field14 = 'top_landmark_index_correct';
            value14 = sortIndex;
            s = struct(field1,value1,field2,value2,field3,value3,field4,value4,field5,value5,...
                field6,value6,field8,value8,...
                field12,value12,field13,value13,field14,value14,field15,value15,...
                field7,value7,field9,value9,field10,value10);
            information{j} = s;
            j = j+1;                
        end
    end
    disp('iteration finish');
    
     %adjust the weight for all the examples together 
    %weightCount = zeros(size(weightMatrix,1),size(weightMatrix,2));
    numExampleMatrix = zeros(size(weightMatrix,1),size(weightMatrix,2));
    for k = 1:size(information,1),
        current = information{k};
        top_inc_lanM = current.top3_landmarks_for_incorrect_class_with_datapoint(1,:);
        index_inc_lanM = current.index_top3_landmarks_for_incorrect_class;
        top_corr_lanM = current.top3_landmarks_for_correct_class_with_datapoint(1,:);
        index_cor_lanM = current.image_top3_landmarks_correct_with_datapoint;
        example = current.top3_landmarks_for_correct_class_with_datapoint(4,:);
        index_exam = current.index_example;    
        %tempWeigtMatrix = weightMatrix;
        incorrSequence = findPathWeight(trainFreeman{index_exam,1},lanFreeman{index_inc_lanM(1),1},weightMatrix);
        incorrSequence = sortrows(incorrSequence,3);
        %corrSequence = findPathWeight(trainFreeman(index_exam,:),lanFreeman(index_cor_lanM(1),:),tempWeigtMatrix);
        %corrSequence = sortrows(corrSequence,-3);  
        %tempExampleMatrix = zeros(size(weightMatrix,1),size(weightMatrix,2));
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
        %numExampleMatrix = numExampleMatrix + tempExampleMatrix;
    end
    %weightCount = weightCount./numExampleMatrix;
    [B,IX] = sort(numExampleMatrix(:),'descend');
    %{
    for i = 1:length(IX),
        %if(B(i)~=0),
            [subRow,subColumn] = ind2sub(size(weightCount),IX(i));
            weightMatrix(subRow,subColumn) = weightMatrix(subRow,subColumn) + 2;
            %break;
        %end
    end  
     %}
    [subRow,subColumn] = ind2sub(size(numExampleMatrix),IX(1));
    weightMatrix(subRow,subColumn) = weightMatrix(subRow,subColumn) + 2;
    disp('iteration finish');
end
disp('finish');






