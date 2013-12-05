numPixel = 28;
numEle = 100;      %number of example of each class
      %total example * dimension of image
numLanM = 10;      %number of landmarks for each class
matrix = zeros((numEle+numLanM)*10,numPixel*numPixel+1);
lanMatrix = zeros(numLanM*10,numPixel*numPixel+1);    %landmark matrix

%read the data and store in matrix
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
horiPro = zeros(10*(numEle+numLanM),3);
for i = 1:10*(numEle+numLanM),
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


featureMatrix = zeros(10*(numEle+numLanM),3);
featureMatrix = horiPro;
%vertical profile
verPro = zeros(10*(numEle+numLanM),3);
for i = 1:10*(numEle+numLanM),
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


%{
%principle component analysis
numPCA = 350;
pca = zeros(10*(numEle+numLanM),numPCA+1);
[pc,score,latent] = princomp(newMatrix(:,1:end-1));
score = score(:,1:numPCA);
pca(:,1:end-1) = score;
pca(:,end) = newMatrix(:,end);
%}

%radial histogram 
degree = 45;
centerRow = numPixel/2;
centerColumn = numPixel/2;
radHis = zeros(10*(numEle+numLanM),8);

numOnes = 0;
for i = 1:10*(numEle+numLanM), 
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
 RadOutIn = zeros(10*(numEle+numLanM),8);
 for i = 1: (numEle+numLanM)*10,
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
 percentageMatrix = zeros(10*(numEle+numLanM),16);
 for i = 1:10*(numEle+numLanM),
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
%{ 
%Radial in-out profile
RadInOut = zeros(10*(numEle+numLanM),8);
 for i = 1:10*(numEle+numLanM), 
    image = reshape(newMatrix(i,1:end-1),[numPixel,numPixel])';
    
    %0 degree
    for j = centerColumn:numPixel,
        if(image(centerRow,j)==1),
            break;
        else
            RadInOut(i,1) = RadInOut(i,1) + 1;
        end
    end
    
    % 45 degree
    for j = centerColumn:numPixel-1,
        if(image(centerRow-(j-centerColumn),j)==1),
            break;
        else
            RadInOut(i,2) = RadInOut(i,2) + 1;
        end
    end
    
    % 90 degree
    for j = centerRow:-1:1,
        if(image(j,centerColumn)==1),
            break;
        else
            RadInOut(i,3) = RadInOut(i,3) + 1;
        end
    end
    
    %135 degree
    for j = centerRow:-1:1,
        if(image(j,centerColumn-(centerRow-j))==1),
            break;
        else
            RadInOut(i,4) = RadInOut(i,4) + 1;
        end
    end
    
    % 180 degree
    for j = centerColumn:-1:1,
        if (image(centerRow,j)==1),
            break;
        else
             RadInOut(i,5) = RadInOut(i,5) + 1;
        end
    end
    
    %225 degree
    for j = centerColumn:-1:1,
        if(image(centerRow+(centerColumn-j),j)==1),
            break;
       
        else        
            RadInOut(i,6) = RadInOut(i,6) + 1;
        end
    end
    
    %270 degree
    for j = centerRow:numPixel,
        if(image(j,centerColumn)==1),
            break;
        else
            RadInOut(i,7) = RadInOut(i,7) + 1;
        end
        
    end
    
    %315 degree
    for j = centerRow:numPixel,
        if(image(j,centerColumn+(j-centerRow))==1),
            break;
        else
            RadInOut(i,8) = RadInOut(i,1) + 1;
        end
    end
 end
 %}
%featureMatrix = [featureMatrix,RadInOut];
numFeature = size(featureMatrix,2);
%{ 
%center of gravity
gravity = zeros(10*(numEle+numLanM),3);
for i = 1: (numEle+numLanM)*10,
    image = reshape(newMatrix(i,1:end-1),[numPixel,numPixel])';
    sumImage = sum(sum(image));
    for j = 1:numPixel,
        for k = 1:numPixel,
            gravity(i,1) = gravity(i,1) + image(j,k)*k/sumImage;
            gravity(i,2) = gravity(i,2) + image(j,k)*(numPixel-j+1)/sumImage;
        end
    end
    gravity(i,3) = newMatrix(i,end);
end
 %}

%Randomly pick some landmarks from each class
lanMatrix = zeros(10*(numLanM),numFeature+1);
trainData = zeros(10*(numEle),numFeature+1);

%store the index for the original dataset
trainIndex = zeros(10*(numEle),1);
lanIndex = zeros(10*(numLanM),1);

%normalize the featureMatrix
average = mean(featureMatrix);


for i = 1:10,
    index = randperm((numLanM+numEle));
    index = index + (i-1)*(numEle+numLanM);
    %lanIndex = index(1:numLanM);
    %trainIndex = index(numLanM+1:end);
    lanIndex((i-1)*(numLanM)+1:(i-1)*(numLanM)+numLanM) = index(1:numLanM);
    %lanMatrix((i-1)*(numLanM)+1:(i-1)*(numLanM)+numLanM,end) = newMatrix(lanIndex,end);
    trainIndex((i-1)*(numEle)+1:(i-1)*(numEle)+numEle) = index(numLanM+1:end);
    %trainData((i-1)*(numEle)+1:(i-1)*(numEle)+numEle,end) = newMatrix(trainIndex,end);
end
trainData(:,1:end-1) = featureMatrix(trainIndex,:);
trainData(:,end) = newMatrix(trainIndex,end);
lanMatrix(:,1:end-1) = featureMatrix(lanIndex,:);
lanMatrix(:,end) = newMatrix(lanIndex,end);


%linear similarity
kernelMatrix = zeros(numEle*10,numLanM*10+1);
featureWeight = ones(numFeature,1);
extraDifference = ones(numLanM*10,numFeature);
%extraDifference = ones(1,numFeature);
addDifference = zeros(numLanM*10,numFeature);

iteration = 50;
accuracyArray = zeros(1,iteration);

for m = 1:iteration,
    for i = 1:numEle*10,
        for j = 1:numLanM*10,
            difference = (trainData(i,1:end-1)-lanMatrix(j,1:end-1));
            difference = abs(difference./average) ;
            difference = difference .* extraDifference(j,:) + addDifference(j,:);
           % difference = difference.* extraDifference;
           difference = sum(difference.^2);
            kernelMatrix(i,j) = exp(-(1/numFeature)*difference);
        end
        kernelMatrix(i,numLanM*10+1) = trainData(i,end);
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

            field7 = 'weights_of_top3_landmarks_for_incorrect_class';
            tempWeights = weights(indexincorrect,:);
            value7 = tempWeights(sortIndex(1:3));

            field10 = 'featurevalue_of_top3_landmarks_for_incorrect_class';
            value10 = [value3(maxIndex)];

            field13 = 'image_top3_landmarks_incorrect_with_datapoint';
            value13 = [newMatrix(lanIndex(maxIndex),:);newMatrix(trainIndex(i),:)];

            field8 = 'top3_landmarks_for_correct_class_with_datapoint';
            [sortedValues,sortIndex] = sort(value5(:),'descend');
            maxIndex = sortIndex(1:3);
            landmark1 = lanMatrix(maxIndex(1),:);
            landmark2 = lanMatrix(maxIndex(2),:);
            landmark3 = lanMatrix(maxIndex(3),:);
            value8 = [landmark1;landmark2;landmark3;trainData(i,:)];

            field9 = 'weights_of_top3_landmarks_for_correct_class';
            tempWeights = weights(indexcorrect,:);
            value9 = tempWeights(sortIndex(1:3));

            field11 = 'featurevalue_of_top3_landmarks_for_correct_class';
            value11 = [value3(maxIndex)];

            field12 = 'image_top3_landmarks_correct_with_datapoint';
            value12 = [newMatrix(lanIndex(maxIndex),:);newMatrix(trainIndex(i),:)];

            field14 = 'top_landmark_index_correct';
            value14 = sortIndex;
            s = struct(field1,value1,field2,value2,field3,value3,field4,value4,field5,value5,field6,value6,field7,value7,field8,value8,field9,value9,field10,value10,field11,value11,field12,value12,field13,value13,field14,value14,field15,value15);
            information{j} = s;
            j = j+1;
            
            

            %display image
            %{
              k = 1;
              figure(1);
              subplot(3,1,1);
              imshow(reshape(information{k,1}.image_top3_landmarks_incorrect_with_datapoint(1,1:end-1),28,28)');
              subplot(3,1,2);  
            imshow(reshape(information{k,1}.image_top3_landmarks_incorrect_with_datapoint(2,1:end-1),28,28)');
               subplot(3,1,3);
            imshow(reshape(information{k,1}.image_top3_landmarks_incorrect_with_datapoint(3,1:end-1),28,28)');
              title('top 3 landmarks for incorrect class');
                figure(2);
                subplot(3,1,1);
              imshow(reshape(information{k,1}.image_top3_landmarks_correct_with_datapoint(1,1:end-1),28,28)');
              subplot(3,1,2);  
                imshow(reshape(information{k,1}.image_top3_landmarks_correct_with_datapoint(2,1:end-1),28,28)');
            subplot(3,1,3);  
            imshow(reshape(information{k,1}.image_top3_landmarks_correct_with_datapoint(3,1:end-1),28,28)');
              title('top 3 landmark for correct class');
              figure(3);
              imshow(reshape(information{k,1}.image_top3_landmarks_correct_with_datapoint(4,1:end-1),28,28)');
            %}      
        end
    end


    for i = 1:numMis,
        %comparison = information{i,1}.top3_landmarks_for_incorrect_class_with_datapoint;
        
        %{
        comparison = information{i,1}.top3_landmarks_for_incorrect_class_with_datapoint;
        for j = 1:numFeature,           
            if(comparison(4,j)==comparison(1,j)&&comparison(4,j)==comparison(2,j)),
               % featureWeight(j) = featureWeight(j) * 1.01;
               index1 = information{i,1}.top_landmark_index_incorrect(1);
               index2 = information{i,1}.top_landmark_index_incorrect(2);
               addDifference(index1,j) = addDifference(index1,j) + 0.01;
               addDifference(index2,j) = addDifference(index2,j) + 0.01;
            end
        end     
        %}
         
        
        comparison = information{i,1}.top3_landmarks_for_correct_class_with_datapoint;
       
        difference1 = comparison(4,1:end-1) - comparison(1,1:end-1);
        difference1 = abs(difference1./average);
        [sortedFeature1,index1] = sort(difference1,'descend');
        
        difference2 = comparison(4,1:end-1) - comparison(2,1:end-1);
        difference2 = abs(difference2./average);
        [sortedFeature2,index2] = sort(difference2,'descend');
        
        difference3 = comparison(4,1:end-1) - comparison(3,1:end-1);
        difference3 = abs(difference3./average);
        [sortedFeature3,index3] = sort(difference3,'descend');
        
        lanMindex1 = information{i,1}.top_landmark_index_correct(1);
        lanMindex2 = information{i,1}.top_landmark_index_correct(2);
        lanMindex3 = information{i,1}.top_landmark_index_correct(3);
        
        
        Lambda = 0.9;
       
        
        extraDifference(lanMindex1,index1(1)) = extraDifference(lanMindex1,index1(1)) * Lambda;
        extraDifference(lanMindex1,index1(2)) = extraDifference(lanMindex1,index1(2)) * Lambda;
        extraDifference(lanMindex1,index1(3)) = extraDifference(lanMindex1,index1(3)) * Lambda;
        extraDifference(lanMindex1,index1(4)) = extraDifference(lanMindex1,index1(4)) * Lambda;
       
        extraDifference(lanMindex2,index2(1)) = extraDifference(lanMindex2,index2(1)) * Lambda;
        extraDifference(lanMindex2,index2(2)) = extraDifference(lanMindex2,index2(2)) * Lambda;
        
        extraDifference(lanMindex3,index3(1)) = extraDifference(lanMindex3,index3(1)) * Lambda;
        extraDifference(lanMindex3,index3(2)) = extraDifference(lanMindex3,index3(2)) * Lambda;
        
        
        %{
        extraDifference(index1(1)) = extraDifference(index1(1)) * Lambda;
        extraDifference(index1(2)) = extraDifference(index1(2)) * Lambda;
        extraDifference(index1(3)) = extraDifference(index1(3)) * Lambda;
        extraDifference(index1(4)) = extraDifference(index1(4)) * Lambda;
       
        extraDifference(index2(1)) = extraDifference(index2(1)) * Lambda;
        extraDifference(index2(2)) = extraDifference(index2(2)) * Lambda;
        
        extraDifference(index3(1)) = extraDifference(index3(1)) * Lambda;
        extraDifference(index3(2)) = extraDifference(index3(2)) * Lambda;
        %}
    
    end
    disp('finish');
end
plot(accuracyArray,'g');



%{
build the new feature space
   RBF kernel
Lambda = power(2,5);
feaMatrix = zeros(numEle*10,numLanM*10+1);
for i = 1:numEle*10,
    for j = 1:numLanM*10,
        newFeature = exp((norm(newMatrix(i,1:end-1) - lanMatrix(j,1:end-1)))/(2*Lambda^2));
        feaMatrix(i,j) = newFeature;
    end
    feaMatrix(i,end) = newMatrix(i,end);
end
%}





%{
split the whole dataset into training set and test set
totalNum = 10*numEle;
numTrain = double(uint32(totalNum * 2/3));
numTest = totalNum - numTrain;
trainData = feaMatrix(1:numTrain,:);
testData = feaMatrix(numTrain+1:end,:);
features_sparse = sparse(trainData(:,1:end-1)); 
%convert the data format into libsvm format
libsvmwrite('training',trainData(:,end),features_sparse);
[label,instance] = libsvmread('training');

%use linear kernel for landmark based features
K1 = [(1:numTrain)',features_sparse];
model = svmtrain(label,K1,'-t 0');
[label,accuracy] = svmpredict(label,instance,model);
disp(accuracy);
%disp(size(feaMatrix));    
%disp(feaMatrix(2,:));
%}

