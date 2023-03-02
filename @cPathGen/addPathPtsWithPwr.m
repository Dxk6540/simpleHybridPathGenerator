        function ret = addPathPtsWithPwr(obj, pts, pwr, lenPos, feedrate)
            constantFeed = 1;
            if(length(pts) ~= length(pwr))
                ret = 0;
                return;
            end
            if(length(pts) ~= length(lenPos))
                ret = 0;
                return;
            end
            if(length(feedrate) == length(pts))
                constantFeed = 0;
            elseif(length(feedrate) == 1)
                constantFeed = 1;
            else
                ret = 0;
                return;                
            end
            
            if(constantFeed == 1)
                fprintf(obj.fid_,"G01 X%.3f Y%.3f Z%.3f I%d J%d F%d\r\n", pts(1,1), pts(1,2), pts(1,3), pwr(1), lenPos(1), feedrate);
                for i = 2:length(pts)          
                    obj.addPathPtWithPwr(pts(i,:), pwr(i), lenPos(i), feedrate);                  
                end
            else
                for i = 1:length(pts)           
                    obj.addPathPtWithPwr(pts(i,:), pwr(i), lenPos(i), feedrate(i));                  
                end
            end
            ret = 1;
        end % addPathPtsWithPwr