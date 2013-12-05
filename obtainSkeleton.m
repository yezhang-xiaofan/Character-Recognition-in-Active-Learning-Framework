function [ result ] = obtainSkeleton( image )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
    image = bwmorph(image,'clean');
    im_t=im2double(image);
    h=fspecial('gaussian');
    imdw =imfilter(im_t,h,'replicate');
    image=im2bw(imdw,graythresh(imdw));
    temp = bwmorph(image,'thin',inf);
    %result = bwmorph(temp,'spur',3);
    %ep = bwmorph(result,'endpoints'); 
    result = temp;
end

