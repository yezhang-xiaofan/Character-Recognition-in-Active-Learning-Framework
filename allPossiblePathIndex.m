function [ result] = allPossiblePathIndex(index_Neighbors,startIndex )
    result = {};
    if(startIndex==size(index_Neighbors,1)),
        final_Index = index_Neighbors{startIndex,1};
        for k = 1:length(final_Index);
            result{size(result,1)+1,1} = final_Index(1,k);
        end
        return;
    end
    
    first_neighborIndex = index_Neighbors{startIndex,1};
    for i = 1:length(first_neighborIndex),
        nextallPossiblePathIndex = allPossiblePathIndex(index_Neighbors,startIndex+1);
        for k = 1:size(nextallPossiblePathIndex,1),
            result{size(result,1)+1,1} = [first_neighborIndex(1,i),nextallPossiblePathIndex{k,1}];
        end
    end
end

