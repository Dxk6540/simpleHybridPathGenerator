function ret = addPathPts(obj, pts, feedrate)
    constantFeed = 1;
    if(length(feedrate) == length(pts))
        constantFeed = 0;
    elseif(length(feedrate) == 1)
        constantFeed = 1;
    else
        ret = 0;
        disp('feedrate sequence err in addPathPts!')
        return;                
    end    
                
    if(constantFeed == 1)
        fprintf(obj.fid_, "G01 X%.3f Y%.3f Z%.3f F%d\r\n", pts(1,1), pts(1,2), pts(1,3), feedrate); 
        for i = 2:size(pts,1)         
            obj.addPathPt(pts(i,:));               
        end
    else
        for i = 1:size(pts,1)           
            obj.addPathPtFeed(pts(i,:), feedrate(i));                  
        end
    end    
    ret = 1;     
end % addPathPts(obj, pts, feedrate)