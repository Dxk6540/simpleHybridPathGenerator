        function ret = addPathPtsWithPwr(obj, pts, pwr, lenPos, feedrate)
            constantFeed = 1;
            if(size(pts,1) ~= size(pwr,1))
                ret = 0;
                return;
            end
            if(size(pts,1) ~= size(lenPos,1))
                ret = 0;
                return;
            end
            if(size(feedrate,1) == size(pts,1))
                constantFeed = 0;
            elseif(size(feedrate,1) == 1)
                constantFeed = 1;
            else
                ret = 0;
                return;                
            end
            
            if(constantFeed == 1)
%                 fprintf(obj.fid_,"G01 X%.3f Y%.3f Z%.3f I%d J%d F%d\r\n", pts(1,1), pts(1,2), pts(1,3), pwr(1), lenPos(1), feedrate);
                for i = 1:size(pts,1)          
                    obj.addPathPtWithPwr(pts(i,:), pwr(i), lenPos(i), feedrate);                  
                end
            else
                for i = 1:size(pts,1)           
                    obj.addPathPtWithPwr(pts(i,:), pwr(i), lenPos(i), feedrate(i));                  
                end
            end
            ret = 1;
        end % addPathPtsWithPwr