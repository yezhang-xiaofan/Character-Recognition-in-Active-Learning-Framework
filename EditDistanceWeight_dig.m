function [V,v] = EditDistanceWeight_dig(string1,string2,weightMatrix,threshold)
% This function limits the DP talbe to the diagonal 
m=length(string1);
n=length(string2);
v=inf(m+1,n+1);
%set the threshold here
newlength_Path = zeros(m+1,n+1);
v(1,1) = 0;
v(1,2) = v(1,1) + weightMatrix(9,string2(1)+1);
v(2,1) = v(1,1) + weightMatrix(string1(1)+1,9);

if(m<=n),
    difference = n-m;
    for i=1:m         
        for j=i-threshold:i+difference+threshold,
            if(j<=0||j>n),
                continue;
            end
            if (string1(i) == string2(j))
                v(i+1,j+1)=v(i,j);
                newlength_Path(i+1,j+1) = newlength_Path(i,j)+1;
            else
                str1 = string1(i);
                str2 = string2(j);
                d1 = v(i,j) + weightMatrix(str1+1,str2+1);
                %insert 
                d2 = v(i+1,j) + weightMatrix(9,str2+1);
                %delete
                d3 = v(i,j+1) + weightMatrix(str1+1,9);
                if(d1==min([d1,d2,d3])),
                   newlength_Path(i+1,j+1) = newlength_Path(i,j) + 1;
                   v(i+1,j+1) = d1;
                elseif(d2==min([d1,d2,d3])),
                   newlength_Path(i+1,j+1) = newlength_Path(i+1,j) + 1;
                   v(i+1,j+1) = d2;
                else               
                   newlength_Path(i+1,j+1) = newlength_Path(i,j+1) + 1;
                   v(i+1,j+1) = d3;       
                end
            end
        
        end
    end
else
    difference = m - n;
    for i=1:m,
        if(i<=difference),
            range_j = 1 : i + threshold;
        elseif(i<n),
           range_j = (i - difference -threshold) : i+threshold ;
        else
            range_j = (i - difference - threshold) :n;
        end
        for k = 1:length(range_j),
            j = range_j(k);
            if(j<=0||j>n),
                continue;
            end
            if (string1(i) == string2(j))
                v(i+1,j+1)=v(i,j);
                newlength_Path(i+1,j+1) = newlength_Path(i,j)+1;
            else
                str1 = string1(i);
                str2 = string2(j);
                d1 = v(i,j) + weightMatrix(str1+1,str2+1);
                %insert 
                d2 = v(i+1,j) + weightMatrix(9,str2+1);
                %delete
                d3 = v(i,j+1) + weightMatrix(str1+1,9);
                if(d1==min([d1,d2,d3])),
                   newlength_Path(i+1,j+1) = newlength_Path(i,j) + 1;
                   v(i+1,j+1) = d1;
                elseif(d2==min([d1,d2,d3])),
                   newlength_Path(i+1,j+1) = newlength_Path(i+1,j) + 1;
                   v(i+1,j+1) = d2;
                else               
                   newlength_Path(i+1,j+1) = newlength_Path(i,j+1) + 1;
                   v(i+1,j+1) = d3;       
                end
            end        
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
    V= 10;
end
end

