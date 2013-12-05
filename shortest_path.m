function [Distance_Matrix ] = shortest_path(Graph, Nodes,weightMatrix)
% calculate the shortest path between each pair of nodes
%Graph is the square matrix denoting a graph
%Nodes is the vector denoting the name of each node
%weightMatrix is the weight of operation
    num_Nodes = length(Nodes);
    %calculate the shortest path for each source vertex
    Distance_Matrix = zeros(num_Nodes,num_Nodes);
    for i = 1:num_Nodes,
        source_Node = Nodes(i);
        dist = inf(1,num_Nodes);
        visited = zeros(1,num_Nodes);
        dist(i) = 0;
        a = java.util.LinkedList;
        a.add(i);      
        while(a.isEmpty==0),
            %choose the smallest distance unvisited node as the current
            %node
            smallest_distance = Inf;
            index_current = -1;
            remove_index = 0;
            for j= 1:a.size,      
                j = j - 1;
                if(dist(a.get(j))<smallest_distance && visited(a.get(j))==0),
                    smallest_distance = dist(a.get(j));
                    index_current = a.get(j);
                    remove_index = j;
                end
            end
            
            visited(index_current) = 1;
            current_Node = index_current;
            a.remove(remove_index);
            
            
            %obtain the neighbors of the current node
            temp_neighbors = Graph(current_Node,:);
            for k = 1:length(temp_neighbors),
                if(temp_neighbors(k) == 1),
                    %accumulate shortest dist from source                                       
                    %neighbor_Node = Nodes(k);
                    if(Graph(k,i) == 1),
                        alt = 0;
                    else
                        alt = dist(current_Node) + weightMatrix(Nodes(current_Node)+1,9);    
                    end
                    %keep the shortest dist from src 
                    if(alt<dist(k) && visited(k) ==0),
                        dist(k) = alt;
                        a.add(k);
                    end
                end                  
            end
            
        end
        Distance_Matrix(i,:) = dist;
    end

end

