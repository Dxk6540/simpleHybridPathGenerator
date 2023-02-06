classdef cPathGen < handle
    %UNTITLED2 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        filename_
        fid_
        curMode_
    end
    
    methods
        function obj = cPathGen(filename)
            obj.filename_ = filename;
        end
        
        function ret = openFile(obj)
        % create the nc file              
            obj.fid_ = fopen(obj.filename_, 'w+');
        end    
        
        function ret = closeFile(obj)
            fclose(obj.fid_);
            ret = 1;
        end            
        
        function ret = closeDoor(obj)
            fprintf(obj.fid_, "M64\n\r");
            fprintf(obj.fid_, "M66\n\r");

            ret = 1;
        end

        function ret = openDoor(obj)
            fprintf(obj.fid_, "M63\n\r");
            fprintf(obj.fid_, "M65\n\r");

            ret = 1;
        end
        
        function ret = pauseProgram(obj)
            fprintf(obj.fid_, "M00\n\r");
            ret = 1;
        end
                
        function ret = endProgram(obj)
            fprintf(obj.fid_, "M30\n\r");
            ret = 1;
        end
        
        function ret = changeMode(obj, mode)
        % 0 is idle, 1 is printing, 2 machining
            if(mode == 1)
                obj.printingMode();
                ret = 0;
            end            
            ret = 0;
        end
        
        function ret = printingMode(obj)
            fprintf(obj.fid_, "M94\n\r");
            fprintf(obj.fid_, "G55\n\r");
            fprintf(obj.fid_, "G49\n\r");
            fprintf(obj.fid_, "M142\n\r");   
            obj.curMode_ = 1;            
            ret = 1;
        end        
        
        function ret = enableLaser(obj, powderMode, delay)
        % powerTurnOnMode = 0, close all; 1 = left powder, 2 = right, 3 = left + right;
        % delay: delay time, unit is second.
            fprintf(obj.fid_, "M351P610\n\r");
            if(powderMode == 1)
                fprintf(obj.fid_, "M351P602\n\r");
            end
            if(powderMode == 2)
                fprintf(obj.fid_, ";M351P604\n\r");
            end
            if(powderMode == 3)
                fprintf(obj.fid_, ";M351P606\n\r");
            end
            
            fprintf(obj.fid_, "G04X%d ;;延时10秒，等待出粉\n\r", delay);
            fprintf(obj.fid_, "M351P600 ;;开启激光\n\r");     
            fprintf(obj.fid_, ";;;;;;;;;;;;;;;;;;;;;;;;;;;运动程序开始\n\r");                 
            ret = 1;
        end       
        
        function ret = disableLaser(obj, powderMode)
        % powerTurnOnMode = 0, close all powder; 1 = close left poweder, 2 = right, 3 = left + right;
            fprintf(obj.fid_, ";;;;;;;;;;;;;;;;;;;;;;;;;;;运动程序结束\n\r");
            fprintf(obj.fid_, "M351P601 ;;关闭激光\n\r");
            fprintf(obj.fid_, "M351P611 ;;关闭熔覆头位置调整\n\r");     
            
            if(powderMode == 1)
                fprintf(obj.fid_, "M351P603 ;;关闭左路送粉\n\r");
            end
            if(powderMode == 2)
                fprintf(obj.fid_, ";M351P605 ;;关闭右路送粉，暂不使用\n\r");
            end
            if(powderMode == 3)
                fprintf(obj.fid_, ";M351P607 ;;关闭左右路送粉，暂不使用\n\r");
            end        
            ret = 1;
        end              
        
        function ret = setLaser(obj, pwr, lenPos, flowL, speedL, flowR, speedR)
            fprintf(obj.fid_, "G01 I%d J%d V%d K%d W%d U%d\n\r", pwr, lenPos, flowL, speedL, flowR, speedR);     
            ret = 1;
        end 
        
        function ret = addCmd(obj, cmd)
            fprintf(obj.fid_, "%s\n\r",cmd);     
            ret = 1;
        end    
        
        function ret = saftyToStart(obj, safetyPath, feedrate)
            % safetyPath is a 3*3 array, with its cols are xyz 
            if(isnan( sum(safetyPath(1,:)) ))
                fprintf(obj.fid_, "G01 Z%.3f F%d\n\r", safetyPath(1,3), feedrate);  
            else
                fprintf(obj.fid_, "G01 X%.3f Y%.3f Z%.3f F%d\n\r", safetyPath(1,1), ...
                    safetyPath(1,2), safetyPath(1,3), feedrate);  
            end
            fprintf(obj.fid_, "G01 X%.3f Y%.3f Z%.3f F%d\n\r", safetyPath(1,1), ...
                safetyPath(1,2), safetyPath(1,3), feedrate);  
            fprintf(obj.fid_, "G01 X%.3f Y%.3f Z%.3f F%d\n\r", safetyPath(1,1), ...
                safetyPath(1,2), safetyPath(1,3), feedrate);                  
        end

        function ret = saftyToPt(obj, pt1, ptDst, feedrate)
            % pt1 is the pt in safety area, pt2 is the dst pt in safety area,
            if(isnan( sum(pt1(1,:)) ))
                fprintf(obj.fid_, "G01 Z%.3f F%d\n\r", pt1(3), feedrate);  
            else
                fprintf(obj.fid_, "G01 X%.3f Y%.3f Z%.3f F%d\n\r", pt1(1), ...
                    pt1(2), pt1(3), feedrate);  
            end
            fprintf(obj.fid_, "G01 X%.3f Y%.3f Z%.3f F%d\n\r", ptDst(1), ...
                ptDst(2), pt1(3), feedrate);  
            fprintf(obj.fid_, "G01 X%.3f Y%.3f Z%.3f F%d\n\r", ptDst(1), ...
                ptDst(2), ptDst(3), feedrate);                 
        end        
        
        function ret = addPathPt(obj, pt)
            fprintf(obj.fid_, "G01 X%.3f Y%.3f Z%.3f\n\r", pt(1), pt(2), pt(3));  
        end
        function ret = addPathPtFeed(obj, pt, feedrate)
            fprintf(obj.fid_, "G01 X%.3f Y%.3f Z%.3f F%d\n\r", pt(1), pt(2), pt(3), feedrate);  
        end
        
        function ret = addPathPts(obj, pts, feedrate)
            fprintf(obj.fid_, "G01 X%.3f Y%.3f Z%.3f F%d\n\r", pts(1,1), pts(1,2), pts(1,3), feedrate);  
            for i = 2:length(pts)
                obj.addPathPt(pts(i,:));
            end
        end

        function ret = addPathPtWithPwr(obj, pt, pwr, lenPos, feedrate)
            fprintf(obj.fid_, "G01 X%.3f Y%.3f Z%.3f I%d J%d F%d\n\r", pt(1), pt(2), pt(3), pwr, lenPos, feedrate);  
        end        
        
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
                fprintf(obj.fid_,"G01 X%.3f Y%.3f Z%.3f I%d J%d F%d\n\r", pts(1,1), pts(1,2), pts(1,3), pwr(1), lenPos(1), feedrate);
                for i = 2:length(pts)
                    if(pwr(i) < 0)
                        obj.addPathPt(pts(i,:));
                        continue;
                    end
                    if(lenPos(i) < 0)
                        obj.addPathPt(pts(i,:));
                        continue;
                    end                
                    obj.addPathPtWithPwr(pts(i,:), pwr(i), lenPos(i), feedrate);                  
                end
            else
                for i = 1:length(pts)
                    if(pwr(i) < 0)
                        obj.addPathPt(pts(i,:), feedrate(i));
                        continue;
                    end
                    if(lenPos(i) < 0)
                        obj.addPathPt(pts(i,:), feedrate(i));
                        continue;
                    end                
                    obj.addPathPtWithPwr(pts(i,:), pwr(i), lenPos(i), feedrate(i));                  
                end
            end
            
        end % addPathPtsWithPwr
        
        
    end
end

