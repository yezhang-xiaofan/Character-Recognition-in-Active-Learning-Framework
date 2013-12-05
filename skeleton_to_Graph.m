function [ Graph,result_Nodes] = skeleton_to_Graph(Skeleton)
%this function converts the skeleton to graph
%Skeleton is the skeleton of digits
%Graph is the graph composed of vertices and edges
index_Pixels = find(Skeleton==1);
coordinate_Array = zeros(1,length(index_Pixels));
%construct adjencency list for 'Skeleton'
hash = java.util.Hashtable;
Nodes = java.util.ArrayList;
for i = 1:length(index_Pixels),
    current_Pixel = index_Pixels(i);
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
       
        temp_Nodes = java.util.ArrayList;
        if(current_coordinate<neighbor),
            temp_Nodes.add(current_coordinate);
            temp_Nodes.add(neighbor);
        else
            temp_Nodes.add(neighbor);
            temp_Nodes.add(current_coordinate);
        end  
        Node_Set.add(temp_Nodes);
    end
    for j = 1:Node_Set.size(),
        tempNodes = Node_Set.get(j-1);        
        if(Graph_Hash.containsKey(tempNodes)==0),
            Nodes.add(tempNodes);
            Graph_Hash.put(tempNodes,java.util.ArrayList);
        end
        index_otherNodes = setdiff(1:Node_Set.size(),j);
        for k = 1:length(index_otherNodes),
            temp_Array = Graph_Hash.get(tempNodes);
            temp_Array.add(Node_Set.get(index_otherNodes(k)-1));
            Graph_Hash.put(tempNodes,temp_Array);
        end
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
        difference = [x1-x2,y1-y2];
        if(difference(1)==0),
            direction = 0;
        elseif(difference(2)==0),
            direction = 2;
        elseif(difference(1) * difference(2) == 1),
            direction = 1;
        else
            direction = 3;
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
end


