%compute freemancoe of image
function [output] = freeman(image)
    h = fspecial('average');
    image = imfilter(image,h,'replicate');
    B = bwboundaries(image,'noholes');
    maxLength = 0;
    for i = 1:size(B,1),
        if(size(B{i,1})>maxLength),
            boundaries = B{i,1};
            maxLength = size(B{i,1});
        end
    end
    output = chaincode(boundaries);
end
