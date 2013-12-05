function [ Direction ] = changeSequencetoDirection( Sequence )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    num_path = size(Sequence,1);
    flagVisited = zeros(28,28);
    startNode = Sequence(1,:);
    flagVisited(startNode(1),startNode(2)) = 1;
    Direction = [];
    for i = 2:num_path,
        tempNode = Sequence(i,:);
        if(flagVisited(tempNode(1),tempNode(2))==1),
            continue;
        end
        previousNode = Sequence(i-1,:);
       
        Difference = tempNode - previousNode;
        if(isequal(Difference,[0,1])),
            Direction = [Direction;0];      
        elseif(isequal(Difference,[-1,1])),
            Direction = [Direction;1];
        elseif(isequal(Difference,[-1,0])),
            Direction = [Direction;2];
        elseif(isequal(Difference,[-1,-1])),
            Direction = [Direction;3];
        elseif(isequal(Difference,[0,-1])),
            Direction = [Direction;4];
        elseif(isequal(Difference,[1,-1])),
            Direction = [Direction;5];
        elseif(isequal(Difference,[1,0])),
            Direction = [Direction;6];
        elseif(isequal(Difference,[1,1])),
            Direction = [Direction;7];
        end    
        flagVisited(tempNode(1),tempNode(2)) = 1;
    end
end

