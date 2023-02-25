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
        end % cPathGen(filename)
        
        function ret = openFile(obj)
        % create the nc file              
            obj.fid_ = fopen(obj.filename_, 'w+');
        end % openFile(obj)   
        
        function ret = closeFile(obj)
            fclose(obj.fid_);
            ret = 1;
        end % closeFile(obj)  

        function ret = recordGenTime(obj)
        % create the nc file     
            timeStr = datestr(datetime, 'yyyy.mm.dd - HH:MM:SS');
            fprintf(obj.fid_, ";;;;;;;;;;;;;generate Time: %s ;;;;;;;;\r\n", timeStr);
        end % openFile(obj)   
        
        function ret = closeDoor(obj)
        % close the door of the machine tool            
            fprintf(obj.fid_, "M64  ;;关侧门\r\n");
            fprintf(obj.fid_, "M66  ;;关主门\r\n");
            ret = 1;
        end % closeDoor(obj)

        function ret = openDoor(obj)
        % open the door of the machine tool
            fprintf(obj.fid_, "M63  ;;开侧门\r\n");
            fprintf(obj.fid_, "M65  ;;开主门\r\n");
            ret = 1;
        end % openDoor(obj)
        
        function ret = pauseProgram(obj)
            fprintf(obj.fid_, "M00 ;;程序暂停，按启动重新启动\r\n");
            ret = 1;
        end % pauseProgram(obj)
                
        function ret = endProgram(obj)
            fprintf(obj.fid_, "M30  ;; end program.\r\n");
            ret = 1;
        end % endProgram(obj)
        
        function ret = changeMode(obj, mode)
        % 0 is idle, 1 is printing, 2 machining
            if(mode == 1)
                obj.printingMode();
                ret = 1;
                return;
            end
            
            if(mode == 2)
                obj.machiningMode();
                ret = 1;
                return;
            end                                    
            ret = 0;
        end % changeMode(obj, mode)
        
        function ret = printingMode(obj)
        % printing mode along with G55 CS + update AIO
            fprintf(obj.fid_, "M94 ;;选择激光模式\r\n");
            fprintf(obj.fid_, "G55 ;; 激光打印选择G55坐标系\r\n");
            fprintf(obj.fid_, "G49  ;;关闭T0的长度补偿\r\n");
            fprintf(obj.fid_, "M142 ;;开启模拟量插补\r\n");   
            obj.curMode_ = 1;            
            ret = 1;
        end % printingMode(obj)       
        
        function ret = machiningMode(obj)
        % printing mode along with G55 CS + update AIO
            fprintf(obj.fid_, "M93 ;;选择主轴模式\r\n");
            fprintf(obj.fid_, "M143 ;;关闭模拟量插补\r\n");
            fprintf(obj.fid_, "G54 ;;主轴选择G54坐标系\r\n");
            obj.curMode_ = 2;            
            ret = 1;
        end % machiningMode(obj)               
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% tool control %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
        
        function ret = enableLaser(obj, powderMode, delay)
        % powerTurnOnMode = 0, close all; 1 = left powder, 2 = right, 3 = left + right;
        % delay: delay time, unit is second.
            fprintf(obj.fid_, "M351P610  ;;开启熔覆头位置调整(上升沿触发)\r\n");
            if(powderMode == 1)
                fprintf(obj.fid_, "M351P602  ;;开启左路送粉\r\n");
            end
            if(powderMode == 2)
                fprintf(obj.fid_, "M351P604  ;;开启右路送粉，暂不使用\r\n");
            end
            if(powderMode == 3)
                fprintf(obj.fid_, "M351P606  ;;开启左右路送粉，暂不使用\r\n");
            end
            
            fprintf(obj.fid_, "G04X%d ;;延时10秒，等待出粉\r\n", delay);
            fprintf(obj.fid_, "M351P600 ;;开启激光\r\n");     
            fprintf(obj.fid_, ";;;;;;;;;;;;;;;;;;;;;;;;;;;运动程序开始\r\n");                 
            ret = 1;
        end  % enableLaser(obj, powderMode, delay)     
        
        function ret = disableLaser(obj, powderMode)
        % powerTurnOnMode = 0, close all powder; 1 = close left poweder, 2 = right, 3 = left + right;
            fprintf(obj.fid_, ";;;;;;;;;;;;;;;;;;;;;;;;;;;运动程序结束\r\n");
            fprintf(obj.fid_, "M351P601 ;;关闭激光\r\n");
            fprintf(obj.fid_, "M351P611 ;;关闭熔覆头位置调整\r\n");     
            
            if(powderMode == 1)
                fprintf(obj.fid_, "M351P603 ;;关闭左路送粉\r\n");
            end
            if(powderMode == 2)
                fprintf(obj.fid_, "M351P605 ;;关闭右路送粉，暂不使用\r\n");
            end
            if(powderMode == 3)
                fprintf(obj.fid_, "M351P607 ;;关闭左右路送粉，暂不使用\r\n");
            end        
            ret = 1;
        end  % disableLaser(obj, powderMode)            
        
        function ret = setLaser(obj, pwr, lenPos, flowL, speedL, flowR, speedR)
            fprintf(obj.fid_, "G01 I%d J%d V%d K%d W%d U%d\r\n", pwr, lenPos, flowL, speedL, flowR, speedR);     
            ret = 1;
        end % setLaser(obj, pwr, lenPos, flowL, speedL, flowR, speedR)
        
        
        function ret = enableSpindle(obj, spindleSpeed, wcsPath)
%             fprintf(obj.fid_, "T1M6 ;;选刀取刀\r\n");
            fprintf(obj.fid_, "S%dM3 ;;启动主轴\r\n", spindleSpeed);     
            fprintf(obj.fid_, "G04X5 ;;等待主轴达到目标转速\r\n");               
%             fprintf(obj.fid_, "G43H1 ;;开刀补\r\n");   
            fprintf(obj.fid_, "M69 ;;开吹气\r\n");               
            fprintf(obj.fid_, ";;;;;;;;;;;;;;;;;;;;;;;;;;;运动程序开始\r\n");               
            ret = 1;
        end  % enableSpindle(obj, spindleSpeed, wcsPath)   
        
        function ret = disableSpindle(obj)
            fprintf(obj.fid_, ";;;;;;;;;;;;;;;;;;;;;;;;;;;运动程序结束\r\n");
            fprintf(obj.fid_,  "M70 ;;关吹气\r\n");
            fprintf(obj.fid_, "M05;;关主轴\r\n");     
               
            ret = 1;
        end  % disableSpindle(obj)   
  

        function ret = changeTool(obj, toolNum)
           if(obj.curMode_ ~= 2)
               disp("changeTool() err! current mode is not machining mode!");
               ret = 0;
               return;
           end
           if(toolNum < 0 || toolNum > 3)
            disp("changeTool() err! toolNum can't find!")
               ret = 0;
               return;               
           end
           if(toolNum == 0)
            fprintf(obj.fid_,  "M7 ;;放刀\r\n");
            fprintf(obj.fid_,  "G49 ;;关闭T0的长度补偿\r\n" );     
            ret = 1;
            return;
           end
            fprintf(obj.fid_, "T%dM6 ;;选刀取刀\r\n", toolNum);     
            fprintf(obj.fid_, "G43H%d ;;开刀补\r\n", toolNum);                 
            ret = 1;            
        end % changeTool(obj, toolNum)
        
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% path control %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function ret = addCmd(obj, cmd)
            fprintf(obj.fid_, "%s\r\n",cmd);     
            ret = 1;
        end  % addCmd(obj, cmd)  
        
        
        function ret = saftyToStart(obj, safetyPath, feedrate)
        % safetyPath is a 3*3 array, with its cols are xyz 
            if(isnan( sum(safetyPath(1,:)) ))
                fprintf(obj.fid_, "G01 Z%.3f F%d\r\n", safetyPath(1,3), feedrate);  
            else
                fprintf(obj.fid_, "G01 X%.3f Y%.3f Z%.3f F%d\r\n", safetyPath(1,1), ...
                    safetyPath(1,2), safetyPath(1,3), feedrate);  
            end
            fprintf(obj.fid_, "G01 X%.3f Y%.3f Z%.3f F%d\r\n", safetyPath(1,1), ...
                safetyPath(1,2), safetyPath(1,3), feedrate);  
            fprintf(obj.fid_, "G01 X%.3f Y%.3f Z%.3f F%d\r\n", safetyPath(1,1), ...
                safetyPath(1,2), safetyPath(1,3), feedrate);                  
        end % saftyToStart(obj, safetyPath, feedrate)

        function ret = saftyToPt(obj, pt1, ptDst, feedrate)
        % pt1 is the pt in safety area, ptDst is the dst pt,
            if(isnan( sum(pt1(1,:)) ))
                fprintf(obj.fid_, "G01 Z%.3f F%d\r\n", pt1(3), feedrate);  
            else
                fprintf(obj.fid_, "G01 X%.3f Y%.3f Z%.3f F%d\r\n", pt1(1), ...
                    pt1(2), pt1(3), feedrate);  
            end
            fprintf(obj.fid_, "G01 X%.3f Y%.3f Z%.3f F%d\r\n", ptDst(1), ...
                ptDst(2), pt1(3), feedrate);  
            fprintf(obj.fid_, "G01 X%.3f Y%.3f Z%.3f F%d\r\n", ptDst(1), ...
                ptDst(2), ptDst(3), feedrate);    
        end % saftyToPt(obj, pt1, ptDst, feedrate)       
        
        function ret = addPathPt(obj, pt)
            fprintf(obj.fid_, "G01 X%.3f Y%.3f Z%.3f\r\n", pt(1), pt(2), pt(3));  
        end % addPathPt(obj, pt)
        function ret = addPathPtFeed(obj, pt, feedrate)
            fprintf(obj.fid_, "G01 X%.3f Y%.3f Z%.3f F%d\r\n", pt(1), pt(2), pt(3), feedrate);  
        end % ddPathPtFeed(obj, pt, feedrate)
        
        function ret = addPathPts(obj, pts, feedrate)
            ret = 1;            
            fprintf(obj.fid_, "G01 X%.3f Y%.3f Z%.3f F%d\r\n", pts(1,1), pts(1,2), pts(1,3), feedrate);  
            for i = 2:length(pts)
                obj.addPathPt(pts(i,:));
            end
        end % addPathPts(obj, pts, feedrate)

        function ret = addPathPtWithPwr(obj, pt, pwr, lenPos, feedrate)
            ret = 1;
            if(pwr < 0)
                obj.addPathPt(pt, feedrate);
                return;
            end
            if(lenPos < 0)
                obj.addPathPt(pt, feedrate);
                return;
            end                        
            fprintf(obj.fid_, "G01 X%.3f Y%.3f Z%.3f I%d J%d F%d\r\n", pt(1), pt(2), pt(3), pwr, lenPos, feedrate);  
        end  % addPathPtWithPwr(obj, pt, pwr, lenPos, feedrate)      
        
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
        
        
    end
end









