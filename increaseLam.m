numPixel = 28;
numEle = 100;      %number of example of each class
      %total example * dimension of image
numLanM = 10;      %number of landmarks for each class

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
    %randomly choose some landmarks from subMatrix
    %landIndex = randperm(numEle+numLanM,numLanM);
    %subLanMatrix = zeros(numLanM,numPixel*numPixel+1);
    %lanMatrix(j*numLanM+1:j*numLanM+numLanM,:) = subMatrix(landIndex,:);
    %subMatrix(landIndex,:) = [];
    matrix(j*(numEle+5*numLanM)+1:j*(numEle+5*numLanM)+numEle+5*numLanM,:) = subMatrix;
end
newMatrix = matrix;

%{
%skeleton
figure(1);
skeletonMatrix = zeros(size(newMatrix,1),size(newMatrix,2));
denoiseMatrix = zeros(size(newMatrix,1),size(newMatrix,2));
for i =1:size(newMatrix,1),
   skeletise = skeleton(reshape(newMatrix(i,1:end-1),28,28)');
   denoiseSkel = removeNoise(skeletise);
   skeletonMatrix(i,1:end-1) = skeletise(:);
   skeletonMatrix(i,end) = newMatrix(i,end);
   denoiseMatrix(i,1:end-1) = denoiseSkel(:);
   denoiseMatrix(i,end) = newMatrix(i,end);
end

k = 1;
for j = 1:10,
    subaxis(3,10,k,'Spacing',0.003,'Padding',0,'Margin',0);
    imshow(reshape(newMatrix((j-1)*(numEle+numLanM)+1,1:end-1),28,28)');
    axis tight
    axis off
    
    subaxis(3,10,k+10,'Spacing',0.003,'Padding',0,'Margin',0);
    imshow(reshape(skeletonMatrix((j-1)*(numEle+numLanM)+1,1:end-1),28,28));
    axis tight
    axis off
    
    subaxis(3,10,k+20,'Spacing', 0.003,'Padding', 0, 'Margin', 0);
    imshow(reshape(denoiseMatrix((j-1)*(numEle+numLanM)+1,1:end-1),28,28));
    axis tight
    axis off
    k = k+1;
end

figure(2);
k = 1;
for j = 1:10,
    subaxis(3,10,k,'Spacing',0.003,'Padding',0,'Margin',0);
    imshow(reshape(newMatrix((j-1)*(numEle+numLanM)+2,1:end-1),28,28)');
    axis tight
    axis off
    
    subaxis(3,10,k+10,'Spacing',0.003,'Padding',0,'Margin',0);
    imshow(reshape(skeletonMatrix((j-1)*(numEle+numLanM)+2,1:end-1),28,28));
    axis tight
    axis off;
    
    subaxis(3,10,k+20,'Spacing', 0.003,'Padding', 0, 'Margin', 0);
    imshow(reshape(denoiseMatrix((j-1)*(numEle+numLanM)+2,1:end-1),28,28));
    axis tight
    axis off
    k = k+1;
end



testIndex = 1;
imshow(reshape(newMatrix(testIndex,1:end-1),[numPixel,numPixel])');
class = sprintf('%d',newMatrix(testIndex,end));
disp(class);
%}


%extract new features
%horizontal profile
featureName = zeros(1,3);
horiPro = zeros(10*(numEle+5*numLanM),3);
for i = 1:10*(numEle+5*numLanM),
    temp = (reshape(newMatrix(i,1:end-1),[numPixel,numPixel])')*ones(numPixel,1);
    temp = sort(temp,'descend');
    temp = temp(1:3);
    horiPro(i,:) = temp;
end

countFeature = 1;
featureName = containers.Map('KeyType','uint32','ValueType','char');
featureName(countFeature) = '1st_hori';
countFeature = countFeature + 1;
featureName(countFeature) = '2nd_hori';
countFeature = countFeature + 1;
featureName(countFeature) = '3rd_hori';
countFeature = countFeature + 1;


featureMatrix = zeros(10*(numEle+5*numLanM),3);
featureMatrix = horiPro;
%vertical profile
verPro = zeros(10*(numEle+5*numLanM),3);
for i = 1:10*(numEle+5*numLanM),
    temp = ones(1,numPixel) * (reshape(newMatrix(i,1:end-1),[numPixel,numPixel])');
    temp = sort(temp,'descend');
    temp = temp(1:3);
    verPro(i,:) = temp;
end
featureMatrix = [featureMatrix,verPro];

featureName(countFeature) = '1st_ver';
countFeature = countFeature + 1;
featureName(countFeature) = '2nd_ver';
countFeature = countFeature + 1;
featureName(countFeature) = '3rd_ver';
countFeature = countFeature + 1;

%radial histogram 
degree = 45;
centerRow = numPixel/2;
centerColumn = numPixel/2;
radHis = zeros(10*(numEle+5*numLanM),8);

numOnes = 0;
for i = 1:10*(numEle+5*numLanM), 
    image = reshape(newMatrix(i,1:end-1),[numPixel,numPixel])';
     %0 degree
    for j = centerColumn:numPixel,
        radHis(i,1) = radHis(i,1) + image(centerRow,j);
    end
    % 45 degree
    for j = centerColumn:numPixel-1,
        radHis(i,2) = radHis(i,2) + image(centerRow-(j-centerColumn),j);
    end
    % 90 degree
    for j = centerRow:-1:1,
        radHis(i,3) = radHis(i,3) + image(j,centerColumn);
    end
    
    %135 degree
    for j = centerRow:-1:1,
        radHis(i,4) = radHis(i,4) + image(j,centerColumn-(centerRow-j));
    end
    
    % 180 degree
    for j = centerColumn:-1:1,
        radHis(i,5) = radHis(i,5) + image(centerRow,j);
    end
    
    %225 degree
    for j = centerColumn:-1:1,
        radHis(i,6) = radHis(i,6) + image(centerRow+(centerColumn-j),j);
    end
    
    %270 degree
    for j = centerRow:numPixel,
        radHis(i,7) = radHis(i,7) + image(j,centerColumn);
    end
    
    %315 degree
    for j = centerRow:numPixel,
        radHis(i,8) = radHis(i,8) + image(j,centerColumn+(j-centerRow));
    end
   
end
featureMatrix = [featureMatrix,radHis];

for i = 1:8,
    featureName(countFeature) = strcat(num2str(i),'th_radHis');
    countFeature = countFeature + 1;
end

%Radial out-in profile
 RadOutIn = zeros(10*(numEle+5*numLanM),8);
 for i = 1: (numEle+5*numLanM)*10,
     image = reshape(newMatrix(i,1:end-1),[numPixel,numPixel])';
     
     %0 degree
     for j = numPixel:-1:centerColumn,
         if(image(centerRow,j)==1),
             break;
         else
             RadOutIn(i,1) = RadOutIn(i,1) + 1;
         end
     end
     
     %45 degree
     for j = 1:centerRow,
         if(image(j,(numPixel-j))==1),
             break;
         else
             RadOutIn(i,2) = RadOutIn(i,2) + 1;
         end
     end
     
     %90 degree
     for j = 1:centerRow,
         if(image(j,centerColumn)==1),
             break;
         else
             RadOutIn(i,3) = RadOutIn(i,3) + 1;
         end
     end
     
     %135 degree
     for j = 1: centerRow,
         if(image(j,j)==1),
             break;
         else
             RadOutIn(i,4) = RadOutIn(i,4) + 1;
         end
     end
     
     %180 degree
     for j = 1: centerColumn,
         if(image(centerRow,j)==1),
             break;
         else
             RadOutIn(i,5) = RadOutIn(i,5) + 1;
         end
     end
         
     %225 degree
     for j = numPixel:-1:centerRow,
         if(image(j,numPixel-j+1)==1),
             break;
         else
             RadOutIn(i,6) = RadOutIn(i,6) + 1;
         end
     end
     
     %270 degree
     for j = numPixel:-1:centerRow,
         if(image(j,centerColumn) == 1),
             break;
         else
             RadOutIn(i,7) = RadOutIn(i,7) + 1;
         end
     end
     
     %315 degree
     for j = numPixel:-1:centerRow,
         if(image(j,j)==1),
             break;
         else
             RadOutIn(i,8) = RadOutIn(i,8) + 1;
         end
     end
    
 end
 featureMatrix = [featureMatrix,RadOutIn];
 for i = 1:8,
    featureName(countFeature) = strcat(num2str(i),'out_in_pro');
    countFeature = countFeature + 1;
 end
 

 %percentage of ones in each grid
 percentageMatrix = zeros(10*(numEle+5*numLanM),16);
 for i = 1:10*(numEle+5*numLanM),
    image = reshape(newMatrix(i,1:end-1),[numPixel,numPixel])';
    for j = 1:4,
        for k = 1:4,
            subimage = image((j-1)*7+1:(j-1)*7+7,(k-1)*7+1:(k-1)*7+7);
            percentage = sum(sum(subimage))/(size(subimage,1)*size(subimage,2));
            percentageMatrix(i,(j-1)*4+k) = percentage;
            
        end
    end
 end
 featureMatrix = [featureMatrix,percentageMatrix];
 for i = 1:16,
    featureName(countFeature) = strcat(num2str(i),'th_perentage');
    countFeature = countFeature + 1;
 end

%featureMatrix = [featureMatrix,RadInOut];
numFeature = size(featureMatrix,2);

%Randomly pick some landmarks from each class
lanMatrix = zeros(10*numLanM,numFeature+1);
trainData = zeros(10*(numEle),numFeature+1);
backupLanMatrix = zeros(10*4*numLanM,numFeature+1);
%store the index for the original dataset
trainIndex = zeros(10*(numEle),1);
allLanIndex = zeros(10*(5*numLanM),1);

%normalize the featureMatrix
average = mean(featureMatrix);


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
trainData(:,1:end-1) = featureMatrix(trainIndex,:);
trainData(:,end) = newMatrix(trainIndex,end);

%choose some landmarks as part of training and others as back-ups. 
lanIndex = zeros(10*numLanM,1);
backupLanIndex = zeros(10*4*numLanM,1);
for i = 1:10,
    index = 1:5*numLanM;
    index = index + (i-1)*(5*numLanM);
    lanIndex((i-1)*numLanM+1:(i-1)*numLanM+numLanM) = allLanIndex(index(1:numLanM));
    backupLanIndex((i-1)*4*numLanM+1:(i-1)*4*numLanM+4*numLanM) = allLanIndex(index(numLanM+1:end));
end
    
lanMatrix(:,1:end-1) = featureMatrix(lanIndex,:);
lanMatrix(:,end) = newMatrix(lanIndex,end);

backupLanMatrix(:,1:end-1) = featureMatrix(backupLanIndex,:);
backupLanMatrix(:,end) = featureMatrix(backupLanIndex,end);

%linear similarity

featureWeight = ones(numFeature,1);
extraDifference = ones(numLanM*10,numFeature);
%extraDifference = ones(1,numFeature);
addDifference = zeros(numLanM*10,numFeature);

iteration = 5;
accuracyArray = zeros(1,iteration);



for m = 1:iteration,
    numLanMark = size(lanMatrix,1);
    kernelMatrix = zeros(numEle*10,numLanMark+1);
    for i = 1:numEle*10,
        for j = 1:numLanMark,
            difference = (trainData(i,1:end-1)-lanMatrix(j,1:end-1));
            difference = abs(difference./average) ;
           % difference = difference .* extraDifference(j,:) + addDifference(j,:);
           % difference = difference.* extraDifference;
           difference = sum(difference.^2);
            kernelMatrix(i,j) = exp(-(1/numFeature)*difference);
        end
        kernelMatrix(i,end) = trainData(i,end);
    end
    training_label_vector = kernelMatrix(:,end);
    training_instance_matrix = kernelMatrix(:,1:end-1);
    %normalize the matrix based on features
    %training_instance_matrix = normc(training_instance_matrix);
    %training_instance_matrix = normr(training_instance_matrix);
    training_instance_matrix = sparse(training_instance_matrix);

    %L1-Loss SVM 
    model = train(training_label_vector,training_instance_matrix,'-s 1 -c 1');
    [predict_label,accuracy,dec_values] = predict(training_label_vector,training_instance_matrix,model);
    accuracyArray(m) = accuracy(1);
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

            %{
            field7 = 'weights_of_top3_landmarks_for_incorrect_class';
            tempWeights = weights(indexincorrect,:);
            value7 = tempWeights(sortIndex(1:3));
            %}

            %{
            field10 = 'featurevalue_of_top3_landmarks_for_incorrect_class';
            value10 = [value3(maxIndex)];
            %}

            field13 = 'image_top3_landmarks_incorrect_with_datapoint';
            value13 = [newMatrix(lanIndex(maxIndex),:);newMatrix(trainIndex(i),:)];

            field8 = 'top3_landmarks_for_correct_class_with_datapoint';
            [sortedValues,sortIndex] = sort(value5(:),'descend');
            maxIndex = sortIndex(1:3);
            landmark1 = lanMatrix(maxIndex(1),:);
            landmark2 = lanMatrix(maxIndex(2),:);
            landmark3 = lanMatrix(maxIndex(3),:);
            value8 = [landmark1;landmark2;landmark3;trainData(i,:)];

            %{
            field9 = 'weights_of_top3_landmarks_for_correct_class';
            tempWeights = weights(indexcorrect,:);
            value9 = tempWeights(sortIndex(1:3));
            %}
            %{
            field11 = 'featurevalue_of_top3_landmarks_for_correct_class';
            value11 = [value3(maxIndex)];
            %}

            field12 = 'image_top3_landmarks_correct_with_datapoint';
            value12 = [newMatrix(lanIndex(maxIndex),:);newMatrix(trainIndex(i),:)];

            field14 = 'top_landmark_index_correct';
            value14 = sortIndex;
            s = struct(field1,value1,field2,value2,field3,value3,field4,value4,field5,value5,field6,value6,field8,value8,...
                field12,value12,field13,value13,field14,value14,field15,value15);
            information{j} = s;
            j = j+1;
           
           %{
              k = 53;
              figure(1);
              subplot(3,1,1);
              imshow(reshape(information{k,1}.image_top3_landmarks_incorrect_with_datapoint(1,1:end-1),28,28)');
              title(strcat(num2str(information{k,1}.top_landmark_index_incorrect(1)),'th landmarks'));
              subplot(3,1,2);  
            imshow(reshape(information{k,1}.image_top3_landmarks_incorrect_with_datapoint(2,1:end-1),28,28)');
              title(strcat(num2str(information{k,1}.top_landmark_index_incorrect(2)),'th landmarks'));   
            subplot(3,1,3);
            imshow(reshape(information{k,1}.image_top3_landmarks_incorrect_with_datapoint(3,1:end-1),28,28)');
             title(strcat(num2str(information{k,1}.top_landmark_index_incorrect(3)),'th landmarks'));   
              
           
                figure(2);
                subplot(3,1,1);
              imshow(reshape(information{k,1}.image_top3_landmarks_correct_with_datapoint(1,1:end-1),28,28)');
               title(strcat(num2str(information{k,1}.top_landmark_index_correct(1)),'th landmarks'));   
              
              subplot(3,1,2);  
                imshow(reshape(information{k,1}.image_top3_landmarks_correct_with_datapoint(2,1:end-1),28,28)');
             title(strcat(num2str(information{k,1}.top_landmark_index_correct(2)),'th landmarks'));
               
             subplot(3,1,3);  
            imshow(reshape(information{k,1}.image_top3_landmarks_correct_with_datapoint(3,1:end-1),28,28)');
               title(strcat(num2str(information{k,1}.top_landmark_index_correct(3)),'th landmarks'));
            
              figure(3);
              imshow(reshape(information{k,1}.image_top3_landmarks_correct_with_datapoint(4,1:end-1),28,28)');
              
            classLan_incorrect = information{k,1}.true_label;
            backupIndex = backupLanIndex(classLan_incorrect*4*numLanM+1:classLan_incorrect*4*numLanM+4*numLanM);
            backup = newMatrix(backupIndex,:);
            figure(4);
            for m = 1:40,
                subplot(6,7,m);
                imshow(reshape(backup(m,1:end-1),28,28)');
                title(strcat(num2str(backupIndex(m)),'th example in the dataset'));
            end
            %}
            
            %replace the bad landmark
            %{
            z2 = 999;
            
            lanMatrix = [lanMatrix;featureMatrix(z2,:),newMatrix(z2,end)];
            lanIndex = [lanIndex;z2];
            %}
            
        end
    end
    disp('iteration finish');
end
disp('finish');






