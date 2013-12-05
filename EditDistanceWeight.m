function [V,v] = EditDistanceWeight(string1,string2,weightMatrix)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
m=length(string1);
n=length(string2);
v=zeros(m+1,n+1);

for i=1:1:m
    str1 = string1(i);
    v(i+1,1)= v(i,1) + weightMatrix(str1+1,9);
end
for j=1:1:n
    str2 = string2(j);
    v(1,j+1)= v(1,j) + weightMatrix(9,str2+1);
end
for i=1:m
    for j=1:n
        if (string1(i) == string2(j))
            v(i+1,j+1)=v(i,j);
        else
            str1 = string1(i);
            str2 = string2(j);
            d1 = v(i,j) + weightMatrix(str1+1,str2+1);
            %insert 
            d2 = v(i+1,j) + weightMatrix(9,str2+1);
            %delete
            d3 = v(i,j+1) + weightMatrix(str1+1,9);
            v(i+1,j+1)=min([d1,d2,d3]);
        end
    end
end
V=v(m+1,n+1);
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
V=v(m+1,n+1);
V=V/pathLength;
end



