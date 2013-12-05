function [V,v] = EditDistance(string1,string2)
% Edit Distance is a standard Dynamic Programming problem. Given two strings s1 and s2, the edit distance between s1 and s2 is the minimum number of operations required to convert string s1 to s2. The following operations are typically used:
% Replacing one character of string by another character.
% Deleting a character from string
% Adding a character to string
% Example:
% s1='article'
% s2='ardipo'
% EditDistance(s1,s2)
% > 4
% you need to do 4 actions to convert s1 to s2
% replace(t,d) , replace(c,p) , replace(l,o) , delete(e)
% using the other output, you can see the matrix solution to this problem
%
%
% by : Reza Ahmadzadeh (seyedreza_ahmadzadeh@yahoo.com - reza.ahmadzadeh@iit.it)
% 14-11-2012

m=length(string1);
n=length(string2);
v=zeros(m+1,n+1);

weightMatrix = [0.00,6.31,7.22,8.61,8.61,9.71,7.14,7.82,6.58;
                6.28,0.00,6.09,9.27,15,8.58,8.17,8.17,6.18;               
                7.14,6.20,0.00,6.77,7.39,9.34,8.24,8.24,6.22;
                15,8.42,6.48,0.00,6.34,7.32,7.32,15,4.67;
                9.69,9.69,7.75,7.80,0.00,7.05,7.90,9.69,7.88;
                7.65,8.57,9.26,15,6.43,0.00,7.27,8.16,7.04;
                7.14,9.34,8.65,8.65,8.24,5.76,0.00,6.70,6.34;
                6.16,7.37,7.77,15,15,8.47,6.83,0.00,5.78;
                6.69,4.77,5.67,6.18,5.52,3.66,6.88,6.18,15];


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

