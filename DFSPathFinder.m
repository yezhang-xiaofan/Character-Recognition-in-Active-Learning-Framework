function [ Path ] = DFSPathFinder(result,startNode)
%Use DFS to trace the path of the digit

d = [0 -1;-1 -1;-1 0;-1 1;0 1;1 -1;1 0;1 1]; 
P = perms([1,2,3,4,5,6,7,8]);
for k = 1:size(P,1),
    flagVisited = zeros(28,28);
    S = CStack;
    S.push(startNode);
    Path = [];
    while(S.isempty()==0),
        tempNode = S.pop();
        if(flagVisited(tempNode(1),tempNode(2))==0),
            flagVisited(tempNode(1),tempNode(2))=1; 
            Path = [Path;tempNode];
            loc =[tempNode(:,1),tempNode(:,2)];
            neighbors = d+repmat(loc,[8 1]);  
            for i = 1:size(neighbors,1),
                neighborNode = neighbors(i,:);
                if(result(neighborNode(1),neighborNode(2))==1)
                    S.push([neighborNode(1),neighborNode(2)]);
                end
            end
        end
    end
end
%}

while(S.isempty()==0),
    tempNode = S.pop();
    if(flagVisited(tempNode(1),tempNode(2))==0),
        flagVisited(tempNode(1),tempNode(2))=1; 
        Path = [Path;tempNode];
        d = [1 0;-1 -1;0 1;-1 1;0 -1;1 -1;-1 0;1 1]; 
        loc =[tempNode(:,1),tempNode(:,2)];
        neighbors = d+repmat(loc,[8 1]);  
        for i = 1:size(neighbors,1),
            neighborNode = neighbors(i,:);
            if(result(neighborNode(1),neighborNode(2))==1)
                S.push([neighborNode(1),neighborNode(2)]);
            end
        end
    end
end
end



