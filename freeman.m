%compute freemancoe of image
function [output] = freeman(image)
    B = bwboundaries(image,'noholes');
    maxLength = 0;
    for i = 1:length(B),
        if(length(B{i})>maxLength),
            boundaries = B{i};
            maxLength = length(B{i});
        end
    end
    output = chaincode(boundaries);
end
