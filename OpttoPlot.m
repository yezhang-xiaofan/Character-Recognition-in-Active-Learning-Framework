function [result] = OpttoPlot(Operation,Sequence)
%convert the optimal operations to a sequence of images 
plot(10,10,'bo');

for i = 1:length(Operation),
    if(Operation(i)<0),
        Conversion{i,1} = strcat('delete ',num2str(-Operation(i)),'th number','cost',...
            num2str(Weight(Sequence(-Operation(i))+1,9)));
        
       
        
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


end

