function [ dGraph, Nodes ] = skeleton_to_dGraph( Skeleton )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%this function converts a skeleton to a directed graph
%Skeleton is the skeleton of digits
%Directed graph is the graph composed of vertices and edges
index_Pixels = find(Skeleton==1);
coordinate_Array = zeros(1,length(index_Pixels));
%construct adjencency list for 'Skeleton'
%adjencency list is stored in 'hash'
%key is the start node
%value is the end nodes starting from the start node
hash = java.util.Hashtable;
Nodes = java.util.ArrayList;
for i = 1:length(index_Pixels),
    [x,y] = ind2sub(size(Skeleton),index_Pixels(i));
    coordinate = index_Pixels(i);
    coordinate_Array(i) = coordinate;
    hash.put(coordinate,java.util.ArrayList);
    d = [ 1 0; -1 0; 1 1; 0 1; -1 1; 1 -1; 0 -1; -1 -1]; 
    neighbors = d+repmat([x,y],[8 1]);    
    liIndex_Neighbor = sub2ind(size(Skeleton),neighbors(:,1)',neighbors(:,2)');
    neighbor_Pixels = Skeleton(liIndex_Neighbor);
    liIndex_nonZeros = find(neighbor_Pixels);
    for j = 1:length(liIndex_nonZeros),
        tempArray = hash.get(coordinate);
        tempArray.add(liIndex_Neighbor(liIndex_nonZeros(j)));
        hash.put(coordinate,tempArray);
    end
end
disp('finish');

Graph_Hash = java.util.Hashtable;
for i = 1:length(index_Pixels),
    current_coordinate = coordinate_Array(i);
    neighbors = hash.get(current_coordinate);
    Node_Set = java.util.ArrayList;    %Node_Set is the 'Nodes' composed by edges between neighbors
    
    %first convert neighbors vertices into a set of 'Nodes' 'Node_Set',
    %each Node is an original edge
    for j = 1:neighbors.size(),
        neighbor = neighbors.get(j-1);  
        tempArray = java.util.ArrayList;
        tempArray.add(current_coordinate);
        tempArray.add(neighbor);
        Node_Set.add(tempArray);
        tempArray = java.util.ArrayList;
        tempArray.add(neighbor);
        tempArray.add(current_coordinate);
        Node_Set.add(tempArray);
    end
    
    %For each Node in the Node_Set, add all the neighboring vertices into the
    %hash table
    for j = 1:Node_Set.size(),
        tempNodes = Node_Set.get(j-1);        
        if(Graph_Hash.containsKey(tempNodes)==0),
            Nodes.add(tempNodes);
            Graph_Hash.put(tempNodes,java.util.ArrayList);
        end
        index_otherNodes = setdiff(1:Node_Set.size(),j);
        temp_Array = Graph_Hash.get(tempNodes);
        for k = 1:length(index_otherNodes),          
            %only add the end Nodes whose first vertex is the the second vertex
            %of the starting Nodes 
            %For example, if the starting Node is (16,15), Node (15,14) is
            %OK?but (14,15) is not fine.
            %(15,16) is not good
            optionalNeighbor = Node_Set.get(index_otherNodes(k) - 1);
            if(tempNodes.get(1)==optionalNeighbor.get(0)&&tempNodes.get(0)~=optionalNeighbor.get(1)),
                temp_Array.add(Node_Set.get(index_otherNodes(k)-1));               
            end            
        end
        Graph_Hash.put(tempNodes,temp_Array);
    end
          
end


    num_Nodes = Nodes.size();
    Graph = zeros(num_Nodes,num_Nodes);
    result_Nodes = zeros(1,num_Nodes);
    for i = 1:num_Nodes,
        current_Node = Nodes.get(i-1);
        coordinate1 = current_Node.get(0);
        coordinate2 = current_Node.get(1);
        [x1,y1] = ind2sub(size(Skeleton),coordinate1);
        [x2,y2] = ind2sub(size(Skeleton),coordinate2);
        difference = [x2-x1,y2-y1];
              
        if(difference(1)==0&&difference(2)==1),
            direction = 0;
        elseif(difference(1)==-1 && difference(2) == 1),
            direction = 1;
        elseif(difference(1) == -1 && difference(2) == 0),
            direction = 2;
        elseif(difference(1) == -1 && difference(2) == -1),
            direction = 3;
        elseif(difference(1) == 0 && difference(2) == -1),
            direction = 4;
        elseif(difference(1) == 1 && difference(2) == -1),
            direction = 5;
        elseif(difference(1) == 1 && difference(2) == 0),
            direction = 6;
        elseif(difference(1) == 1 && difference(2) == 1),
            direction = 7;
        end
        result_Nodes(i) = direction;
        
        %obtain the neighbors
        neighbors = Graph_Hash.get(current_Node);
        for k = 1:neighbors.size(),
            neighbor = neighbors.get(k-1);
            Graph(i,Nodes.indexOf(neighbor)+1) = 1;
        end
    end  
    for i = 1:num_Nodes,
        Graph(i,i) = 1;
    end
    dGraph = Graph;
    Nodes = result_Nodes;
    disp('finish');
end

