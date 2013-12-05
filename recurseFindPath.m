function [ Path ] = recurseFindPath(result,flagVisited,startNode)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
     if(flagVisited(startNode(1),startNode(2))==1||result(startNode(1),startNode(2))==0),
         Path = {};
         return;
     end
     d = [0 -1;-1 -1;-1 0;-1 1;0 1;1 -1;1 0;1 1]; 
     loc = startNode;
     neighbors = d+repmat(loc,[8 1]);   
     
     %obtain the neighbors that have not been visited
     Path = {startNode};
      flagVisited(startNode(1),startNode(2)) = 1;  
      neighborIndex = sub2ind(size(result), neighbors(:,1),neighbors(:,2));
     C = intersect(find(flagVisited(neighborIndex)==0),(find(result(neighborIndex)==1)));
      neighbors = neighbors(C,:);
      num_neighbors = size(neighbors,1);
      if(num_neighbors==0),
          return;
      end      
      mapObj = containers.Map(0,{{0}});
      for i = 1:num_neighbors,
          tempFlagVisted = flagVisited;
          neighborNode = neighbors(i,:);
          neighborPath = recurseFindPath(result,tempFlagVisted,neighborNode);
          neighborCoordinate = sub2ind(size(result),neighborNode(1),neighborNode(2));
          mapObj(neighborCoordinate) = neighborPath;
      end
      
      V = linspace(1,num_neighbors,num_neighbors);
      P = perms(V);
      
      resultPath = {};
      for p = 1:size(P,1),           %for each ordering of neighbors
          %build index for each neighor
          tempNeighbors = neighbors(P(p,:),:);           
          index_neighbors = {};
          for q = 1:size(tempNeighbors,1),
              neighbor = tempNeighbors(q,:);
              neighborCoordinate = sub2ind(size(result),neighbor(1),neighbor(2));
              num_Path = size(mapObj(neighborCoordinate),1);
              index_neighbors{size(index_neighbors,1)+1,1} = linspace(1,num_Path,num_Path);
          end
          allPossibleIndex = allPossiblePathIndex(index_neighbors,1);
       
          k = 1;
          for m = 1:size(allPossibleIndex,1),   %for each possible combination of paths
              tempPathIndex = allPossibleIndex{m,1};
              tempResult = [];
              tempVisitedFlag = flagVisited;
              for n = 1:length(tempPathIndex),    %for a certain combination of path
                  intermediate = [startNode];
                  neighbor = tempNeighbors(n,:);
                  neighborCoordinate = sub2ind(size(result),neighbor(1),neighbor(2));
                  neighborPath = mapObj(neighborCoordinate); 
                  tempPath = neighborPath{tempPathIndex(1,n),1};
                  for z = 1:size(tempPath,1),     %add one path to the result
                      pixel = [tempPath(z,1),tempPath(z,2)];
                      if(tempVisitedFlag(pixel(1),pixel(2))==0),
                          intermediate = [intermediate;pixel];
                          tempVisitedFlag(pixel(1),pixel(2)) = 1;
                      end
                  end
                  if(size(intermediate,1)>1),
                    tempResult = [tempResult;intermediate];
                  end
              end
              
              if(k==1),
                  previousPath = [tempResult];
                  resultPath{size(resultPath,1)+1,1} = [tempResult];
                  k = k + 1;
                  continue;
              end              
              %check whether this path is equal to the previous path
              if(isequal([tempResult],previousPath)==0),
                  resultPath{size(resultPath,1)+1,1} = [tempResult];
                  %disp([startNode;tempResult]);
                  previousPath = [tempResult];
                  k = k + 1;
              end
          end          
      end      
      Path =resultPath;
      length_Path = size(Path{1,1},1);
      x1 = cellfun(@(y)y(:)', Path, 'UniformOutput',0);
        x2 = cell2mat(x1);
        x3 = unique(x2,'rows');
        x4 = num2cell(x3,2);
        x5 = cellfun(@(y) reshape(y,length_Path,2), x4, 'UniformOutput',0); 
        Path = x5;
end     
          
      
      
      
      
      
      
      
      
      
      
      


