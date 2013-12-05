%count the number of neighbors

% count the number of pixel neighbors.
% Neighbors only, so don't count the center pixel.
load('image4');
imageArray = image4;
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
disp('finish');