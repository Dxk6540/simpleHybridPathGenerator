classdef cPathGen < handle
    %UNTITLED2 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        filename_
        fid_
        curMode_
        draw_
        experiment_
        alternation_
    end
    
    methods
        function obj = cPathGen(filename)
            obj.filename_ = filename;
        end % cPathGen(filename)
        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%% file control %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%              
        ret = openFile(obj);
        
        ret = closeFile(obj);
        
        ret = recordGenTime(obj);
        
        ret = genNewScript(obj);
        
        ret = closeScript(obj);
                        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% peripheral control %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                   

        ret = closeDoor(obj)
        
        ret = openDoor(obj)        
        
        ret = pauseProgram(obj)   
        
        ret = pauseProgramMust(obj)
        
        ret = endProgram(obj)

        % changeMode(obj, mode): mode 0 is idle, 1 is printing, 2 machining
        ret = changeMode(obj, mode)  
        
        ret = printingMode(obj)    
        
        ret = machiningMode(obj)



        function ret = laserProtection(obj, status)
        % printing mode along with G55 CS + update AIO
            if status == 1
                fprintf(obj.fid_, "M144 ;;装保护头\r\n");           
            elseif status == 0
                fprintf(obj.fid_, "M145 ;;放保护头\r\n");                
            end
            ret = 1;
        end % laserProtection(obj, status)   
                
        function ret = stay(obj, time)
        % printing mode along with G55 CS + update AIO
            if time > 0
                fprintf(obj.fid_, "G04X%d ;;延时\r\n", time);     
            else 
                fprintf(obj.fid_, "G04X5 ;;延时\r\n");                 
            end
            ret = 1;
        end % laserProtection(obj, status)   

        
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% tool control %%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      

        % enableLaser(obj, powderMode, delay):powerTurnOnMode = 0, close all; 1 = left powder, 2 = right, 3 = left + right;
        % delay: delay time for powder, unit is second.
        ret = enableLaser(obj, powderMode, delay)

        % disableLaser(obj, powderMode): powerTurnOnMode = 0, close all powder; 1 = close left poweder, 2 = right, 3 = left + right;        
        ret = disableLaser(obj, powderMode)
               
        function ret = setLaser(obj, pwr, lenPos, flowL, speedL, flowR, speedR)
%             fprintf(obj.fid_, "G01 I%d J%d V%d K%d W%d U%d\r\n", pwr, lenPos, flowL, speedL, flowR, speedR);  
            fprintf(obj.fid_, "M146 I%d J%d V%d K%d W%d U%d\r\n", pwr, lenPos, flowL, speedL, flowR, speedR); 
            % G01 is not stable,             
            % use M146(single step update) to change the analog value.
            ret = 1;
        end % setLaser(obj, pwr, lenPos, flowL, speedL, flowR, speedR)
        
        ret = changePowder(obj, flowL, speedL, flowR, speedR, delay);
        
        ret = enableSpindle(obj, spindleSpeed, wcsPath)        
        ret = disableSpindle(obj)
        ret = changeTool(obj, toolNum)
        
        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% path control %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function ret = startRTCP(obj, safetyHeight, toolNum)
            obj.saftyToPt([nan, nan, safetyHeight], [0, 0, safetyHeight], 1500);
            obj.addPathPt([0, 0, safetyHeight, 0, 0]);
            fprintf(obj.fid_, "G43.4H%d\r\n",toolNum);
            ret = 1;
        end
        
        function ret = stopRTCP(obj, safetyHeight, toolNum)
%             obj.saftyToPt([nan, nan, safetyHeight],[0, 0, safetyHeight], 1500);
%             obj.addPathPt([0, 0, safetyHeight, 0, 0]);    
            fprintf(obj.fid_, "G49\r\n");   
            fprintf(obj.fid_, "G43H%d ;;开刀补\r\n", toolNum);                   
            obj.returnToSafety(safetyHeight, 3000);
            ret = 1;
        end

        function ret = addCmd(obj, cmd)
            fprintf(obj.fid_, "%s\r\n",cmd);     
            ret = 1;
        end  % addCmd(obj, cmd)  
        
        
        function ret = returnToSafety(obj, zDist, feedrate)
            fprintf(obj.fid_, "G01 Z%.3f F%d\r\n", zDist, feedrate);                 
        end % returnToSafety(obj, safetyPath, feedrate)
        
        
        function ret = saftyToPt(obj, ptMediate, ptDst, feedrate)
        % pt1 is the pt in safety area, ptDst is the dst pt,
            if(isnan( sum(ptMediate(1,:)) ))
                fprintf(obj.fid_, "G01 Z%.3f F%.3f\r\n", ptMediate(3), feedrate);  
            else
                fprintf(obj.fid_, "G01 X%.3f Y%.3f Z%.3f F%.3f\r\n", ptMediate(1), ...
                    ptMediate(2), ptMediate(3), feedrate);  
%                 obj.addPathPtFeed(ptMediate, feedrate);
            end
            fprintf(obj.fid_, "G01 X%.3f Y%.3f Z%.3f F%.3f\r\n", ptDst(1), ...
                ptDst(2), ptMediate(3), feedrate);  
            fprintf(obj.fid_, "G01 X%.3f Y%.3f Z%.3f F%.3f\r\n", ptDst(1), ...
                ptDst(2), ptDst(3), feedrate);    
        end % saftyToPt(obj, pt1, ptDst, feedrate)       
        
        
        function ret = addPathPt(obj, pt)
            if(length(pt) == 3)
                fprintf(obj.fid_, "G01 X%.3f Y%.3f Z%.3f\r\n", pt(1), pt(2), pt(3));  
            elseif (length(pt) == 5)
                fprintf(obj.fid_, "G01 X%.3f Y%.3f Z%.3f B%.3f C%.3f\r\n", pt(1), pt(2), pt(3), pt(4), pt(5));  
            else
                disp("error in addPathPt! the pt is neither 3 or 5 dim!")
            end
        end % addPathPt(obj, pt)
        
        
        function ret = addPathPtFeed(obj, pt, feedrate)
            if(length(pt) == 3)
                fprintf(obj.fid_, "G01 X%.3f Y%.3f Z%.3f F%.3f\r\n", pt(1), pt(2), pt(3), feedrate);  
                ret = 1;
                return;
            elseif (length(pt) == 5)
                fprintf(obj.fid_, "G01 X%.3f Y%.3f Z%.3f B%.3f C%.3f F%.3f\r\n", pt(1), pt(2), pt(3), pt(4), pt(5), feedrate);  
                ret = 1;
                return;
            else
                disp("error in addPathPt! the pt is neither 3 or 5 dim!")
            end            
            ret = 0;
            return;
        end % ddPathPtFeed(obj, pt, feedrate)
               
        function ret = addPathPtWithPwr(obj, pt, pwr, lenPos, feedrate)
            ret = 1;
            if(pwr < 0)
                obj.addPathPtFeed(pt, feedrate);
                return;
            end
            if(lenPos < 0)
                obj.addPathPtFeed(pt, feedrate);
                return;
            end                        
            if(length(pt) == 3)
                fprintf(obj.fid_, "G01 X%.3f Y%.3f Z%.3f I%d J%d F%.3f\r\n", pt(1), pt(2), pt(3), pwr, lenPos, feedrate);                  
                ret = 1;
                return;
            elseif (length(pt) == 5)
                fprintf(obj.fid_, "G01 X%.3f Y%.3f Z%.3f B%.3f C%.3f I%d J%d F%.3f\r\n", pt(1), pt(2), pt(3), pt(4), pt(5), pwr, lenPos, feedrate);                  
                ret = 1;
                return;
            else
                disp("error in addPathPt! the pt is neither 3 or 5 dim!")
            end            
            ret = 0;
            return;            
        end  % addPathPtWithPwr(obj, pt, pwr, lenPos, feedrate)      
        

       
        function ret = addPathPtWithAll(obj, pt, pwr, lenPos, flowL, speedL, flowR, speedR, feedrate)
            ret = 1;
            if(pwr < 0)
                obj.addPathPtFeed(pt, feedrate);
                return;
            end
            if(lenPos < 0)
                obj.addPathPtFeed(pt, feedrate);
                return;
            end    
            if(flowL < 0 | speedL < 0 | flowR < 0 | speedR < 0)
                obj.addPathPtFeed(pt, feedrate);
                return;
            end                
            if(length(pt) == 3)
                fprintf(obj.fid_, "G01 X%.3f Y%.3f Z%.3f I%d J%d V%d K%d W%d U%d F%.3f\r\n", ...
                                  pt(1), pt(2), pt(3), pwr, lenPos, flowL, speedL, flowR, speedR, feedrate);                  
                ret = 1;
                return;
            elseif (length(pt) == 5)
                fprintf(obj.fid_, "G01 X%.3f Y%.3f Z%.3f B%.3f C%.3f I%d J%d V%d K%d W%d U%d F%.3f\r\n", ...
                    pt(1), pt(2), pt(3), pt(4), pt(5), pwr, lenPos, flowL, speedL, flowR, speedR, feedrate);                  
                ret = 1;
                return;
            else
                disp("error in addPathPt! the pt is neither 3 or 5 dim!")
            end            
            ret = 0;
            return;            
        end  % addPathPtWithAll(obj, pt, pwr, lenPos, feedrate)              
        
        ret = addPathPts(obj, pts, feedrate);
        ret = addPathPtsWithPwr(obj, pts, pwr, lenPos, feedrate);
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% draw path %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        function drawPath(obj, pPathSeq, mPathSeq)
            
            figure();
            plot3(pPathSeq(:,1),pPathSeq(:,2),pPathSeq(:,3));
            axis equal;
            figure();
            plot3(mPathSeq(:,1),mPathSeq(:,2),mPathSeq(:,3));
            axis equal;
            
        end
    end
end









