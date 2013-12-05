function [ result] = removeNoise( image )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    imageArray = image;
    iteration = 4;
    kernel = [1 1 1; 1 0 1; 1 1 1]; % If using 8-connectivity

for i = 1:iteration,
    
    pixelCounts = conv2(single(imageArray), kernel, 'same');
    % Mask by original image.
    pixelCounts = pixelCounts .* single(imageArray);

    % Find which pixels have exactly 1 neighbor
    onlyOneNeighbor = (pixelCounts == 1);

    % Set those to zero
    outputImage = imageArray;
    outputImage(onlyOneNeighbor) = 0;
    imageArray = outputImage;
end
result = imageArray;
            

end

