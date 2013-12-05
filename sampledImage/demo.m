%to find the skeleton pruned image with branch points,%end points of image with black background using inbuilt %functions in MATLAB
 
clc;
clear all;
close all;
 
% read the image file
%[im_original,map]=imread('image51.fig');
load('image52');
im_original = image52;
subplot(2,2,1)
imshow(im_original)
title('original image')
 
% if the original image is a RGB image then get binary %image
%imbw=im2bw(im_original,map,0.9);
imbw = im2bw(im_original);
subplot(2,2,2)
imshow(imbw);
title('original image converted to black&white image')
 

% No need for complementing binary image so 'comp_imbw=imcomplement(imbw)' is not needed;
 
%to transform background into completely dark and remove %noise in the image using filter function
im_t=imfill(imbw,'holes');
im_t=im2double(im_t);
h=fspecial('gaussian',25,15);
imdw =imfilter(im_t,h,'replicate');
imdw=im2bw(imdw,1.5*graythresh(imdw));
subplot(2,2,3)
imshow(imdw);
title('background filled  image ')
 
%to get skeleton pruned image
skel_img1=bwmorph(imdw,'skel',inf);
 
%to remove noisy branches in the skeleton pruned image
skel_img = bwmorph(skel_img1,'spur',10);
 

%to find edges in the gray scle image using sobel %approximation
edges=edge(skel_img,'sobel');
 
subplot(2,2,4)
imshow (skel_img+edges);
title('skeleton pruned image')
 
ep = bwmorph(skel_img,'endpoints');
bp = bwmorph(skel_img,'branchpoints');
[x1,y1] = find(ep);
[x2,y2] = find(bp);
 
 
figure(2),imshow(skel_img+edges)
hold on 
plot(y1,x1,'ro','LineWidth',1,...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor','r',...
                'MarkerSize',8)           
plot(y2,x2,'gO','LineWidth',1,...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor','g',...
                'MarkerSize',8)
 
 legend('Endpoints','branchpoints',2);
 
 axis on
 hold off
