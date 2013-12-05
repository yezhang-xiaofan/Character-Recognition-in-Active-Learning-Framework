%draw skeleton
figure(1);
for i =0:9,
    file = strcat('sampledimage/image',num2str(i));
    load(file);
    image = eval(strcat('image',num2str(i)));
    subplot(2,10,i+1);
    imshow(image);
    subplot(2,10,10+i+1);
    imshow(obtainSkeleton(image));
end