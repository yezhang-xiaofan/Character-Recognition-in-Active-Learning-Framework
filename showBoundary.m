function [ boundary ] = showBoundary( image )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    B = bwboundaries(image,'noholes');
    maxLength = 0;
    for i = 1:length(B),
        if(length(B{i})>maxLength),
            maxLength = length(B{i});
            boundary = B{i};
        end
    end
end

