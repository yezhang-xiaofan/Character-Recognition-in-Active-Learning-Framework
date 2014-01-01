%Use the graph-based algorithm to train SVM
numPixel = 28;
numEle = 10;      %number of examples of each class
initial_num_lanM = 2;     
load('trainIndex.mat');
load('trainData.mat');
load('newMatrix.mat');
load('LanIndex');
load('LanMatrix');
load('InitialSequences');
addpath('/Users/zhangye/Documents/Study/cmu/study/research/handwritten/');
smallData = zeros(10*numEle,28*28+1);
for i = 1:10,
    smallData((i-1)*numEle+1:(i-1)*...
        numEle+numEle,:) = trainData((i-1)*40+1:(i-1)*40+numEle,:);
end
trainData = smallData;
%convert the training instances into graph
training_Graph = {};
for i = 1:size(trainData,1),  
    train_Image = reshape(trainData(i,1:end-1),28,28)';
    [Graph,Nodes]= skeleton_to_dGraph(obtainSkeleton(train_Image));
    training_Graph{1,i}.Graph = Graph;
    training_Graph{1,i}.Nodes = Nodes;
end
%compute kernel matrix

weightMatrix = [0.00,6.31,7.22,8.61,8.61,9.71,7.14,6.82,3.38;
                6.28,0.00,6.09,9.27,15,8.58,8.17,8.17,3.18;               
                7.14,6.20,0.00,6.77,7.39,9.34,8.24,8.24,3.22;
                15,8.42,6.48,0.00,6.34,7.32,7.32,15,2.67;
                9.69,9.69,7.75,6.80,0.00,7.05,7.90,9.69,3.58;
                7.65,8.57,9.26,15,6.43,0.00,6.27,8.16,3.04;
                7.14,9.34,8.65,8.65,8.24,5.76,0.00,6.70,3.34;
                6.16,7.37,7.77,15,15,8.47,5.83,0.00,2.78;
                3.69,3.77,3.67,4.18,3.52,3.66,3.88,4.18,15];
            
    threshold = 100;
    sigma = 1;
    kernelMatrix = zeros(numEle*10,size(Sequences,2)+1);
    width = 3;
    for i = 1:100
       for j = 9:10,
            tic;
            if(iscell(Sequences{1,j})==0)
                distance = find_shortest_distance_narrowDP(Sequences{1,j},...
                training_Graph{1,i}.Graph,training_Graph{1,i}.Nodes,weightMatrix,threshold,width);
            else
                distance = find_shortest_distance_narrowDP_twoSeq(Sequences{1,j},...
                training_Graph{1,i}.Graph,training_Graph{1,i}.Nodes,weightMatrix,threshold,width);
            end
            %kernelMatrix(i,j) = exp(-distance^2/sigma);
            toc;
            kernelMatrix(i,j) = distance;
       end
       kernelMatrix(i,end) = trainData(i,end);
    end
    
    newKernel = kernelMatrix;
    newKernel (find(kernelMatrix==inf)) = 400;
     mean = sum(sum(newKernel(:,1:end-1)))/(size(newKernel,1)*(size(kernelMatrix,2)-1));
    optional_Sigma = [mean, mean/2, mean*2, mean/4, mean*4];
      opt_accuracy = 0;
        for i = 1:length(optional_Sigma),
            opt_Sigma = optional_Sigma(i);
           %opt_Sigma = 2.55;
            training_label_vector = newKernel(:,end);
            training_instance_matrix = newKernel(:,1:end-1);
            training_instance_matrix = exp(-(training_instance_matrix.^2)/(opt_Sigma));
            training_instance_matrix = normr(training_instance_matrix);
            training_instance_matrix = sparse(training_instance_matrix);        
            model = train(training_label_vector,training_instance_matrix,'-s 1 -c 1'); 
            [predict_label,accuracy,dec_values] = predict(training_label_vector,training_instance_matrix,model);
            if(accuracy(1)>opt_accuracy),
                opt_accuracy = accuracy(1);
               % accuracy_Array(m) = accuracy(1);               
            end
        end   
    if(accuracy(1)>minAccuracy),
        minAccuracy = accuracy(1);       
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
 
    
    %adjust the weight for all the examples together 
  
        weightCount = zeros(size(weightMatrix,1),size(weightMatrix,2));   
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
    
    
    [B,IX] = sort(numExampleMatrix(:),'descend');
    [subRow,subColumn] = ind2sub(size(numExampleMatrix),IX(1));
    weightMatrix(subRow,subColumn) = weightMatrix(subRow,subColumn) + 2;
        end
    
    
    disp('iteration finish');
disp('finish');






