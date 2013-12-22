function [V,v] = EditDistanceWeightPosition(string1,string2,weightMatrix,cost_Deletion,...
    cost_Insert,threshold)
%Calculate the edit distance between two characters according to weight
%matrix and the position in the freeman code
m=length(string1);
n=length(string2);
v=zeros(m+1,n+1);
position = 10;
%cost of insertion and deletion depend on the position

newlength_Path = zeros(m+1,n+1);
for i=1:1:m
    str1 = string1(i);
    v(i+1,1)= v(i,1) + cost_Deletion(1,str1+1,i);
    newlength_Path(i+1,1) = newlength_Path(i,1) + 1;
end
for j=1:1:n
    str2 = string2(j);
    v(1,j+1)= v(1,j) + cost_Insert(1,str2+1,j);
    newlength_Path(1,j+1) = newlength_Path(1,j) + 1;
end

for i=1:m
    for j=1:n
        if(v(i,j)==inf && v(i+1,j) ==inf && v(i,j+1) ==inf),
            v(i+1,j+1) = inf;
            continue;
        end
        if (string1(i) == string2(j))
            v(i+1,j+1) = v(i,j);
            newlength_Path(i+1,j+1) = newlength_Path(i,j)+1;
        else
            str1 = string1(i);
            str2 = string2(j);
            d1 = v(i,j) + weightMatrix(str1+1,str2+1);
            
            %insert 
            d2 = v(i+1,j) + cost_Insert(1,str2+1,i);
            
            %delete
            d3 = v(i,j+1) + cost_Deletion(1,str1+1,j);
            
            v(i+1,j+1)=min([d1,d2,d3]);
            if(d1==min([d1,d2,d3])),
               newlength_Path(i+1,j+1) = newlength_Path(i,j) + 1;
            elseif(d2==min([d1,d2,d3])),
               newlength_Path(i+1,j+1) = newlength_Path(i+1,j) + 1;
            else
               newlength_Path(i+1,j+1) = newlength_Path(i,j+1) + 1;
            end
        end
        if((v(i+1,j+1)/newlength_Path(i+1,j+1))>=threshold),
            v(i+1,j+1) = inf;
        end
    end
end
V=v(m+1,n+1);
%{
[row,column] = size(v);
%path = cell(100,1);
pathLength = 0;
k = row;
j = column;
while(k>1||j>1),
        d1 = inf;
        d2 = inf;
        d3 = inf;
        if(k>1);
            prestr1 = string1(k-1);
            d1 = v(k-1,j) + weightMatrix(prestr1+1,9);
        end
        if(j>1),
            prestr2 = string2(j-1);
            d2 = v(k,j-1) + weightMatrix(9,prestr2+1);
        end
        if(k>1&&j>1),
            prestr1 = string1(k-1);
            prestr2 = string2(j-1);
            d3 = v(k-1,j-1) + weightMatrix(prestr1+1,prestr2+1);
        end
        
        if(d1==min([d1,d2,d3])),
            k = k - 1;      
            pathLength = pathLength + 1;
        elseif(d2==min([d1,d2,d3]))
            j = j - 1;
            pathLength = pathLength + 1;
        else
            k = k - 1;
            j = j - 1;
            pathLength = pathLength + 1;
        end  
end
%}
V=V/newlength_Path(m+1,n+1);
if(V==inf),
    V= 100;
end
end

