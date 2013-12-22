function [ Path ] = find_Path(i,j,next,dist)
%this function constructs the path from 'next' obtained by FloydWarshall
%algorithm
%dist is the distance matrix 
Path = [];
if dist(i,j) == inf,
    Path = inf;
    return;
end
intermediate = next(i,j);
if(intermediate == inf),       %i and j are neighbors
    return;
else

    Path = [find_Path(i,intermediate,next,dist),intermediate,find_Path(intermediate,j,next,dist)];
    return;
end

