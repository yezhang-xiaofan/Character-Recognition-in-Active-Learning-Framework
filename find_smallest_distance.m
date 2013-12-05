function [ distance,Weight,Operation,Conversion] = find_smallest_distance( Sequence,Graph,Nodes,Weight)
% This function calculates the smallest distance between a sequence of the
% landmark and a Graph
%Sequence is the sequence of directions (0,1,2,3,4,5,6,7) for a landmark
%Graph is the graph representation for a given character. Each vertex
%denotes a direction
%Nodes is the vertex name of each node in the Graph. It is a vector
% Operation is the sequence of operations to convert the Sequence to graph
%single positive number denotes insertion 
%single negative number denotes deletion
% otherwise positive number denotes conversion (least significant number is the name of the Node)
% higher digits is the 10* index of node in the sequence
%for example, 1234 is conversion from 123th number in the sequence to 4. 
%Conversion is the description about the conversion
tic;
length_Seq = length(Sequence);
[Distance_Matrix,next] = FloydWarshall(Graph,Nodes,Weight);
num_Nodes = length(Nodes);
Distance = zeros(num_Nodes,num_Nodes,length_Seq);

%obtain the path between each pair 
path = cell(num_Nodes,num_Nodes);
for i = 1:num_Nodes,
    for j = 1:num_Nodes,
        path{i,j} = find_Path(i,j,next,Distance_Matrix);
    end
end

%first obtain the distance of S_1 -> A,
Dis_FirsttoSingle = zeros(1,num_Nodes);
Opt_FirsttoSingle = cell(1,num_Nodes);
for i = 1:num_Nodes,
    temp_Node = Nodes(i);
    Seq = Sequence(1);
    cost1 = Weight(Seq+1,temp_Node+1);
    cost2 = Weight(Seq+1,9) + Weight(9,temp_Node+1);
    if(cost1>cost2),
        Weight(Seq+1,temp_Node+1) = cost2;
    end
    Dis_FirsttoSingle(1,i) = min(cost1,cost2);
    Opt_FirsttoSingle{1,i} = 10*1 + temp_Node;
end

% S_k -> A
Dis_SingletoSingle = zeros(1,num_Nodes,length_Seq);
Dis_SingletoSingle(:,:,1) = Dis_FirsttoSingle;
Opt_SingletoSingle = cell(1,num_Nodes,length_Seq);
Opt_SingletoSingle(:,:,1) = Opt_FirsttoSingle;
for i = 2:length_Seq,
    Seq = Sequence(i);
    for j = 1:num_Nodes,
        temp_Node = Nodes(j);    
        cost1 = Weight(Seq+1,temp_Node+1);
        cost2 = Weight(Seq+1,9) + Weight(9,temp_Node+1);
        if(cost1>cost2),
            Weight(Seq+1,temp_Node+1) = cost2;
        end
        Dis_SingletoSingle(1,j,i) = Weight(Seq+1,temp_Node+1);
        Opt_SingletoSingle{1,j,i} = 10*i + temp_Node;  
    end
end

%distance S_1 -> AB
Seq = Sequence(1);
Dis_FirsttoPair = zeros(num_Nodes,num_Nodes);
path_FirsttoPair = cell(num_Nodes,num_Nodes);
Opt_FirsttoPair = cell(num_Nodes,num_Nodes);
for i = 1:num_Nodes,
    for j = 1:num_Nodes,
        Nodes_between = Nodes(path{i,j});
        if(j==i)
           Dis_FirsttoPair(i,j) = Dis_FirsttoSingle(i);
           Opt_FirsttoPair{i,j} = Opt_FirsttoSingle{1,i};
           continue;
        end
        start_Node = Nodes(i);
        end_Node = Nodes(j);
        min_Cost = inf;
        %  (S_1 -> A) + d(A-B) + insert(B)
        cost1 = Weight(Seq+1,start_Node+1) + Distance_Matrix(i,j) +...
            Weight(9,end_Node+1);
        if(cost1<min_Cost),
            min_Cost = cost1;
            path_FirsttoPair{i,j} = path{i,j};
            Opt_FirsttoPair{i,j} = [10*1+start_Node,Nodes_between,...
                end_Node];
        end
        
        % (S_1 ->B) + d(A-B) + insert(A)
        cost2 = Weight(Seq+1,end_Node+1) + Distance_Matrix(i,j) + ...
            Weight(9,start_Node+1);
        if(cost2<min_Cost),
            min_Cost = cost2;
            path_FirsttoPair{i,j} = path{i,j};
            Opt_FirsttoPair{i,j} = [start_Node,Nodes_between,Opt_FirsttoSingle{1,j}];
        end
        
        % insert(A) + d(A-C) + (S_1 ->C ) + + d(C-B)  + insert(B)
        for k = 1:num_Nodes,
            if(k==i || k==j),
                continue;
            end
            med_Node = Nodes(k);
            temp_Cost = Weight(Seq+1,med_Node+1) + Distance_Matrix(i,k) + ...
                Distance_Matrix(k,j) + Weight(9,start_Node+1) + Weight(9,end_Node+1);
            if(temp_Cost<min_Cost),
                Nodes_between1 = Nodes(path{i,k});
                Nodes_between2 = Nodes(path{k,j});
                min_Cost = temp_Cost;
                path_FirsttoPair{i,j} = [path{i,k},k,path{k,j}];
                Opt_FirsttoPair{i,j} = [start_Node,Nodes_between1,...
                   Opt_FirsttoSingle{1,k},Nodes_between2,end_Node];
            end
        end
        Dis_FirsttoPair(i,j) = min_Cost;
    end
end

%S_1,S_2,...,S_k -> A
SeqtoSingle = zeros(1,num_Nodes,length_Seq);
Opt_SeqtoSingle = cell(1,num_Nodes,length_Seq);
SeqtoSingle(:,:,1) = Dis_FirsttoSingle;
Opt_SeqtoSingle(:,:,1) = Opt_SingletoSingle(:,:,1);
for i = 2:length_Seq,
    End_Seq = Sequence(i);
    %S_1,S_2,...S_i -> Nodes(j)
    for j = 1:num_Nodes,
        target_Node = Nodes(j);
        min_Cost = inf;
        for k = 1:i,
            %cost of deleting sequences except k
            %delete(S_1) + delete(S_2) ...+(S_k -> A) +
            %delete(S_k+1)...+delete(S_i) 
            keep_Seq = Sequence(k);
            delete_Seq1 = 1:k-1;
            if(k+1<=i)
                delete_Seq2 = Sequence(k+1:i);
            else
                delete_Seq2 = [];
            end
            cost_Delete = 0;
            for p = 1:i,
                if(p~=k)
                 cost_Delete = cost_Delete + Weight(Sequence(p)+1,9);
                end                
            end
            total_cost = Weight(keep_Seq+1,target_Node+1) + cost_Delete;
            if(total_cost<min_Cost),
                min_Cost = total_cost;
                SeqtoSingle(1,j,i) = Weight(keep_Seq+1,target_Node+1) + cost_Delete;
                Opt_SeqtoSingle{1,j,i} = [-delete_Seq1,...
                    Opt_SingletoSingle{1,j,k},-delete_Seq2];
            end            
        end
    end
end

%S_k -> AB
SingletoPair = zeros(num_Nodes,num_Nodes,length_Seq);
path_SingletoPair = cell(num_Nodes,num_Nodes,length_Seq);
SingletoPair(:,:,1) = Dis_FirsttoPair;
path_SingletoPair(:,:,1) = path_FirsttoPair;
opt_SingletoPair = cell(num_Nodes,num_Nodes,length_Seq);
opt_SingletoPair(:,:,1) = Opt_FirsttoPair;
for k = 2:length_Seq,
    Seq = Sequence(k);
    for i = 1:num_Nodes,
        for j = 1:num_Nodes,
           if(i==j),
               opt_SingletoPair{i,i,k} = Opt_SingletoSingle{1,i,k};
               SingletoPair(i,i,k) = Dis_SingletoSingle(1,i,k);
               continue;
           end
           min_Cost = inf;
           start_Node = Nodes(i);
           end_Node = Nodes(j);           
           for p = 1:num_Nodes,
               % S_k -> A + d(A->B) + insert(B)
               if(p==i),
                    cost = Weight(Seq+1,start_Node+1) +Distance_Matrix(i,j) + Weight(9,end_Node+1);
                    if(cost<min_Cost),
                        min_Cost = cost;
                        path_SingletoPair{i,j,k} = path{i,j};
                        opt_SingletoPair{i,j,k} = [k*10+start_Node,Nodes(path{i,j}),end_Node];
                    end
               % insert(A) + d(A->B) + S_k -> B
               elseif(p==j),
                    cost = Weight(9,start_Node+1) + Distance_Matrix(i,j) + Weight(Seq+1,end_Node+1);
                    if(cost<min_Cost),
                        min_Cost = cost;
                        path_SingletoPair{i,j,k} = path{i,j};
                        opt_SingletoPair{i,j,k} = [start_Node,Nodes(path{i,j}),k*10+end_Node];
                    end                              
               % insert(A) + + d(A->C) + (S_k -> C) + d(C->B) + insert(B)
               else
                   med_Node = Nodes(p);
                   cost = Weight(9,start_Node+1)+ Distance_Matrix(i,p) +...
                       Distance_Matrix(p,j) + Weight(Seq+1,med_Node+1) + Weight(9,end_Node+1);
                   if(cost<min_Cost),
                       min_Cost = cost;
                       temp_Path = [path{i,p},p,path{p,j}];
                       Nodes_between1 = Nodes(path{i,p});
                       Nodes_between2 = Nodes(path{p,j});
                       opt_SingletoPair{i,j,k} = [Nodes_between1,Opt_SingletoSingle{1,p,k},...
                           Nodes_between2];    
                       path_SingletoPair{i,j,k} = temp_Path;   
                   end
               end
           end
           SingletoPair(i,j,k) = min_Cost;       
        end
    end       
end

%obtain the distance of S_1,S_2..S_k -> AB
DistanceMatrix = zeros(num_Nodes,num_Nodes,length_Seq);
pathMatrix = cell(num_Nodes,num_Nodes,length_Seq);
DistanceMatrix(:,:,1) = Dis_FirsttoPair;
pathMatrix(:,:,1) = path_FirsttoPair;
Opt_Path = cell(num_Nodes,num_Nodes,length_Seq);
Opt_Path(:,:,1) = Opt_FirsttoPair;
for k = 2:length_Seq,
    seq = Sequence(k);
    for i = 1:num_Nodes,
        for j = 1:num_Nodes,
            if(i==j),            %S_1,S_2,...,S_k ->A
                DistanceMatrix(i,j,k) = SeqtoSingle(1,j,k);
                Opt_Path{i,i,k} = Opt_SeqtoSingle{1,i,k};
                continue;
            end
            start_Node = Nodes(i);
            end_Node = Nodes(j);       
            min_Cost = inf;            
            %consider the single median node   
            % insert(A) + (A->C) + (S_1,S_2,...,S_k-> C) + (C->B) +
            % insert(B)
            for p = 1:num_Nodes,
                if(p==i)
                    cost = SeqtoSingle(1,i,k) + Distance_Matrix(i,j) + Weight(9,end_Node+1);
                    if(cost<min_Cost),
                        min_Cost = cost;
                        temp_Path = path{i,j};
                        Opt_Path{i,j,k} = [Opt_SeqtoSingle{1,p,k},Nodes(path{p,j}),end_Node];
                    end
                elseif(p==j),
                    cost = Weight(9,start_Node+1) + Distance_Matrix(i,j) + SeqtoSingle(1,j,k);
                    if(cost<min_Cost),
                        min_Cost = cost;
                        temp_Path = path{i,j};
                        Opt_Path{i,j,k} = [start_Node,Nodes(path{i,j}),Opt_SeqtoSingle{1,p,k}];
                    end
                else
                    med_Node = Nodes(p);
                    cost = Weight(9,start_Node+1)+ Weight(9,end_Node+1)+...
                        SeqtoSingle(1,p,k-1) + Distance_Matrix(i,p) + Distance_Matrix(p,j);
                    if(cost<min_Cost)
                        min_Cost = cost;                      
                        temp_Path = [pathMatrix{i,p,k-1},p,pathMatrix{p,j,k-1}];
                        Opt_Path{i,j,k} = [start_Node,Nodes(path{i,p}),Opt_SeqtoSingle{1,p,k},...
                            Nodes(path{p,j}),end_Node];
                    end
                end
            end
            
            %consider two median nodes
            % (S_1,S_2,...,S_k-1 ->AC_1) + (C_1,C_2) + (S_k -> C_2B)
            for p = 1:num_Nodes,
                med_Node1 = Nodes(p);
                Neighbors = Graph(p,:);
                index = find(Neighbors~=0);
                for q = 1:length(index),
                    if(index(q)==p)
                        continue;
                    end
                    med_Node2 = Nodes(index(q));
                    cost = DistanceMatrix(i,p,k-1) + SingletoPair(index(q),j,k);
                    if(cost<min_Cost),
                        min_Cost = cost;
                        if(p~=i && index(q)~=j),
                            temp_Path = [pathMatrix{i,p,k-1},p,index(q),...
                                path_SingletoPair{index(q),j,k}];
                        elseif(p==i && index(q)~=j),
                            temp_Path = [index(q),path_SingletoPair{index(q),j,k}];
                        elseif(index(q)==j && p~=i),
                            temp_Path = [pathMatrix{i,p,k-1},p];
                        else
                            temp_Path = [];
                        end                           
                        Opt_Path{i,j,k} = [Opt_Path{i,p,k-1},opt_SingletoPair{index(q),j,k}];
                    end
                end
            end
            pathMatrix{i,j,k} = temp_Path;
            DistanceMatrix(i,j,k) = min_Cost;
        end
    end                        
end

%calculate shortest distance in DistanceMatrix{i,j,k}
min_Cost = inf;
Opt_whole = [];
for i = 1:num_Nodes,
    for j = 1:num_Nodes,
        cost_insert = 0;
        temp_Node = unique([pathMatrix{i,j,k},i,j]);
        index_insert = setdiff(1:num_Nodes,temp_Node);
        %insert all nodes in the 'insert_Node'. 
        for p = 1:length(index_insert),
            cost_insert = cost_insert + Weight(9,Nodes(index_insert(p))+1);
        end        
        if(DistanceMatrix(i,j,k) + cost_insert < min_Cost)
            min_Cost = DistanceMatrix(i,j,k) + cost_insert;
            start_Node = i;
            end_Node = j;
            Opt_whole = [Opt_Path{i,j,k},Nodes(index_insert)];
        end
    end
end
distance = min_Cost;
Operation = Opt_whole;
Conversion = {};
for i = 1:length(Operation),
    if(Operation(i)<0),
        Conversion{i,1} = strcat('delete ',num2str(-Operation(i)),'th number','cost',...
            num2str(Weight(-Operation(i)+1,9)));
    elseif(Operation(i)>=10),
        Original = idivide(int32(Operation(i)),int32(10),'floor');
        target = rem(Operation(i),10);
        Conversion{i,1} = strcat('change ',num2str(Original),'th number to',num2str(target),...
            'cost',num2str(Weight(Sequence(Original)+1,target+1)));
    else
        Conversion{i,1} = strcat('insert ',num2str(Operation(i)),'cost',...
            num2str(Weight(9,Operation(i)+1)));
    end
end
disp('finish');
toc;



