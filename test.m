%test shortest_path algorithm

weightMatrix = [0.00,6.31,7.22,8.61,8.61,9.71,7.14,6.82,3.38;
                6.28,0.00,6.09,9.27,15,8.58,8.17,8.17,3.18;               
                7.14,6.20,0.00,6.77,7.39,9.34,8.24,8.24,3.22;
                15,8.42,6.48,0.00,6.34,7.32,7.32,15,2.67;
                9.69,9.69,7.75,6.80,0.00,7.05,7.90,9.69,3.58;
                7.65,8.57,9.26,15,6.43,0.00,6.27,8.16,3.04;
                7.14,9.34,8.65,8.65,8.24,5.76,0.00,6.70,3.34;
                6.16,7.37,7.77,15,15,8.47,5.83,0.00,2.78;
                3.69,3.77,3.67,4.18,3.52,3.66,3.88,4.18,15];
%{
for i = 1:8,
    for j = 1:8,
        if(j<i),
            
        elseif(j>4),
            weightMatrix(i,j) = weightMatrix(i,j-4);
        end
            weightMatrix(i,j) = weightMatrix(i-4,j);
    end      
end

weightMatrix(5,9) = weightMatrix(1,9);
weightMatrix(6,9) = weightMatrix(2,9);
weightMatrix(7,9) = weightMatrix(3,9);
weightMatrix(8,9) = weightMatrix(4,9);
weightMatrix(9,1) = weightMatrix(9,5);
weightMatrix(9,2) = weightMatrix(9,6);
weightMatrix(9,3) = weightMatrix(9,7);
weightMatrix(9,4) = weightMatrix(9,8);
%}

                
% convert sequence of B to the graph of three
%{
Sequences = [6,6,6,6,7,6,5,7,6,5];
skeleton = zeros(28,28);
skeleton(10,11) = 1;
skeleton(10,12) = 1;
skeleton(11,11) = 1;
skeleton(11,12) = 1;
skeleton(12,11) = 1;
skeleton(12,12) = 1;
[Graph,Nodes] = skeleton_to_dGraph(skeleton);
[distance,WeightMatrix,operations,Conversion] = find_smallest_distance(Sequences,Graph,Nodes,weightMatrix);
%}

%{
Sequences = [0,6,6,4];
skeleton = zeros(28,28);
skeleton(10,10) = 1;
skeleton(10,11) = 1;
skeleton(11,11) = 1;
skeleton(12,11) = 1;
skeleton(12,10) = 1;
[Graph,Nodes] = skeleton_to_dGraph(skeleton);
[distance,WeightMatrix,operations,Conversion] = find_smallest_distance(Sequences,Graph,Nodes,weightMatrix);
%}

%convert sequence of zero to the graph of zero 
%{
Skeleton = zeros(28,28);
Skeleton(10,10) = 1;
Skeleton(10,11) = 1;
Skeleton(11,10) = 1;
Skeleton(11,11) = 1;
[Graph,Nodes] = skeleton_to_dGraph(Skeleton);
Sequences = [0,6,4,2];

[distance,WeightMatrix,operations,Conversion] = find_smallest_distance(Sequences,Graph,Nodes,weightMatrix);
 %}

%convert the sequence zero to the graph of 1

Skeleton = zeros(28,28);
Skeleton(10,10) = 1;
Skeleton(11,10) = 1;
Skeleton(12,10) = 1;
[Graph,Nodes] = skeleton_to_dGraph(Skeleton);
Sequences = [6,6,6,6,6,6,6,6,6,6,6,6,6,6,6];
%[distance,WeightMatrix,operations,Conversion] = find_smallest_distance(Sequences,Graph,Nodes,weightMatrix);

[distance,WeightMatrix,operations,Conversion] = find_shortest_distance_narrowDP(Sequences,...
    Graph,Nodes,weightMatrix,5,20);

%{
Skeleton = zeros(28,28);
Skeleton(10,10) = 1;
Skeleton(10,11) = 1;
Skeleton(11,11) = 1;
Skeleton(11,10) = 1;
Skeleton(12,10) = 1;
Skeleton(12,11) = 1;
[Graph,Nodes] = skeleton_to_dGraph(Skeleton);
Sequence = [0,6,4,0,6,4];
[distance,WeightMatrix] = find_smallest_distance(Sequence,Graph,Nodes,weightMatrix);
%}


%test the function 'skeleton_to_Graph'. 
%skeleton = zeros(28,28);
%{
for i = 5:20,
    skeleton(i,10) = 1;
    skeleton(i,18) = 1;
end
for i = 10:18,
    skeleton(5,i) = 1;
    skeleton(20,i) = 1;
    skeleton(15,i) = 1;
end
%}

%{
skeleton = zeros(28,28);
for i = 10:14,
    skeleton(i,10) = 1;
end
for i = 10:14,
    skeleton(i,12) = 1;
end
skeleton(10,11) = 1;
skeleton(14,11) = 1;
skeleton(12,11) = 1;

Graph = skeleton_to_dGraph(skeleton);
%}

%{
Skeleton = zeros(28,28);
for i = 10:12,
    Skeleton(i,10) = 1;
end
Skeleton(11,9) = 1;
Skeleton(11,11) = 1;
Graph = skeleton_to_dGraph(Skeleton);
%}

%test 'FloydWarshall'
%{
Nodes = [1,4,5,3,4,3];
Graph = zeros(6,6);
Graph(1,2) = 1;
Graph(2,3) = 1;
Graph(3,4) = 1;
Graph(4,5) = 1;
Graph(3,6) = 1;
for i = 1:6,
    Graph(i,i) = 1;
end
FloydWarshall(Graph,Nodes,weightMatrix);
%}


