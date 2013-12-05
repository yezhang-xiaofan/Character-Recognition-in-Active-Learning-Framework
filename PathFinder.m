%recursively find all the possible path on a digit

function [Path] = PathFinder(result,startNode,flagVisited)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here                    
                d = [0 -1;-1 -1;-1 0;-1 1;0 1;1 -1;1 0;1 1]; 
                loc =[startNode(:,1),startNode(:,2)];
                neighbors = d+repmat(loc,[8 1]);  
               flagVisited(startNode(1),startNode(2))=-1;   
                %determine whether the startNode has neighbors
                linearIndex = sub2ind(size(result),neighbors(:,1)',neighbors(:,2)');
                if(isempty(find(result(linearIndex)))==1),
                    Path = {startNode};
                    return;
                end
                Path = {};
                AllPossiblePath = {};
                for j = 1:size(neighbors,1),  
                    tempFlagVisited = flagVisited;
                    if(flagVisited(neighbors(j,1),neighbors(j,2))==0),
                        if(result(neighbors(j,1),neighbors(j,2))==1),                 
                            neighborNode = [neighbors(j,1),neighbors(j,2)];
                            %tempCurrentPath = currentPath;
                            %for p = 1:size(tempCurrentPath,1),    
                             %   tempCurrentPath{p,1} = [tempCurrentPath{p,1};neighborNode];
                            %end
                            tempPath1 = PathFinder(result,neighborNode,tempFlagVisited);                                                     
                            for p = 1:size(tempPath1,1),
                                AllPossiblePath{size(AllPossiblePath,1)+1,1} = tempPath1{p,1};
                            end
                        end
                    end
                end
                for m = 1:size(AllPossiblePath,1),
                    Path{size(Path,1)+1,1} = [startNode;AllPossiblePath{m,1}];
                end
                flagVisited(startNode(1),startNode(2)) = 1;              
                if(size(Path,1)==0),
                    Path = {startNode};
                     return;
                end
                    
end

