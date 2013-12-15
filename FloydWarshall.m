function [ dist, next ] = FloydWarshall(Graph, Nodes,Weight)
%this function calculates the shortest path between any pair in the Graph
% and construct the path between them

%dist is a |V| * |V| matrix of minumum distances initialized to infinity
num_Nodes = length(Nodes);
dist = inf(num_Nodes,num_Nodes);

%next is a |V| * |V| matrix of vertex indices
%it stores the information about the highest index intermediate vertex one
%must pass through if one wishes to arrive at any given vertex. 
next = inf(num_Nodes,num_Nodes);
for i = 1:num_Nodes,
    Neighbors = Graph(i,:);
    for j = 1:num_Nodes,
        if(Neighbors(j)==1),
            dist(i,j) = 0;
            next(i,j) = 0;
        end
    end
end

for k = 1:num_Nodes,
    for i = 1:num_Nodes,
        for j = 1:num_Nodes,
            med_Node = Nodes(k);
            cost = dist(i,k) + dist(k,j) + Weight(9,med_Node+1);
            if(cost<dist(i,j))
                dist(i,j) = cost;
                next(i,j) = k;
            end
        end
    end
end
%{
for i = 1:num_Nodes,
    for j = 1:num_Nodes,
        if(dist(i,j) == inf),
            
            %if two nodes are not connected by a path, set the distance
            %between them large
            dist(i,j) = 15;
        end
    end
end
%}
disp('finish');






