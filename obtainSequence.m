%obtain skeleton of digit
function [Path,result] = obtainSequence(image)
    numPixel = 28;
    image = bwmorph(image,'clean');
    image=im2double(image);
    %h=fspecial('gaussian');
    %imdw =imfilter(im_t,h,'replicate');
    %image=im2bw(imdw,graythresh(imdw));
    %image = bwmorph(image,'close');
    %image = bwmorph(image,'clean');
    result = bwmorph(image,'thin',inf);
    %result = bwmorph(result,'spur',3);
    result = bwmorph(result,'clean');
    result = bwmorph(result,'skel',inf);
    ep = bwmorph(result,'endpoints');
    bp = bwmorph(result,'branchpoints');
    [endRow,endColumn] = find(ep);
    [branchRow,branchColumn] = find(bp);
    start = [endRow,endColumn];
    branch = [branchRow,branchColumn];
    Path = {};
    
    if(isempty(start)==1),%set the top point as the start point
        flag = 0;
        for i = 1:size(image,1),
            if(flag==1),
                break;
            end
            for j = 1:size(image,2),
                if(result(i,j)==1),
                    start = [i,j];
                    flag = 1;
                    break;
                end
            end
        end
    end
    for i = 1:size(start,1),
        flagVisited = zeros(numPixel,numPixel);
        %currentPath = {start(i,:)};
        Path{size(Path,1)+1,1} = recurseFindPath(result,flagVisited,start(i,:));        
    end
    
end

