function [ result ] = findPathWeight(string1,string2,weightMatrix,threshold)
%This function finds the path to match string1 to string2 
%threshold is the width deviation from the diagonal
    [V,v] = EditDistanceWeight(string1,string2,weightMatrix,threshold);
   
[row,column] = size(v);
path = cell(100,1);
m = 1;
k = row;
j = column;

%construct path matrix
pathMatrix = zeros(200,2);
while(k>1||j>1),
        d1 = inf;
        d2 = inf;
        d3 = inf;
        if(k>1),
            prestr1 = string1(k-1);
            d1 = v(k-1,j) + weightMatrix(prestr1+1,9);
        end
        if(j>1),
            prestr2 = string2(j-1);
            d2 = v(k,j-1) + weightMatrix(9,prestr2+1);
        end
        if(k>1&&j>1)
            prestr1 = string1(k-1);
            prestr2 = string2(j-1);
            d3 = v(k-1,j-1) + weightMatrix(prestr1+1,prestr2+1);
        end
        if(d1==min([d1,d2,d3])),           %deletion
            path{m,1} = ['de',blanks(1),num2str(string1(k-1)),blanks(1),num2str(weightMatrix(prestr1+1,9))];            
            pathMatrix(m,1) = sub2ind(size(weightMatrix),prestr1+1,9);
            pathMatrix(m,2) = weightMatrix(prestr1+1,9);
            m = m + 1;
            k = k - 1;
            
        elseif(d2==min([d1,d2,d3])),  %insertion
            path{m,1} = ['in',blanks(1),num2str(string2(j-1)),blanks(1),num2str(weightMatrix(9,prestr2+1))];
            pathMatrix(m,1) = sub2ind(size(weightMatrix),9,prestr2+1);
            pathMatrix(m,2) = weightMatrix(9,prestr2+1);
            m = m + 1;
            j = j - 1;
        else   %substitution
            path{m,1} = ['sub',blanks(1),num2str(string1(k-1)),blanks(1),'with',blanks(1),num2str(string2(j-1)),...
                blanks(1),num2str(weightMatrix(prestr1+1,prestr2+1))];
            pathMatrix(m,1) = sub2ind(size(weightMatrix),prestr1+1,prestr2+1);
            pathMatrix(m,2) = weightMatrix(prestr1+1,prestr2+1);
            m = m + 1;
            k = k - 1;
            j = j - 1;
        end  
end
%{
result = cell(m,1);
k = 1;
for i = m:-1:2,
    result{k,1} = path{i-1,1};
    k = k + 1;
end
%}
tempresult = flipud(pathMatrix(1:m-1,:));
[I,J] = ind2sub(size(weightMatrix),tempresult(:,1)');  
result = [I',J',tempresult(:,2)];
end

        

