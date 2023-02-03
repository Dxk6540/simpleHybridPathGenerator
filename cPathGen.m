classdef cPathGen < handle
    %UNTITLED2 �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    
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
            fprintf(obj.fid_, "M64  ;;�ز���\n");
            fprintf(obj.fid_, "M66  ;;������\n");

            ret = 1;
        end

        function ret = openDoor(obj)
            fprintf(obj.fid_, "M63 ;;������\n");
            fprintf(obj.fid_, "M65 ;;������\n");

            ret = 1;
        end
        
        function ret = pauseProgram(obj)
            fprintf(obj.fid_, "M00 ;;������ͣ����������������\n");
            ret = 1;
        end
                
        function ret = endProgram(obj)
            fprintf(obj.fid_, "M30 ;; end program.\n");
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
            fprintf(obj.fid_, "M94 ;;ѡ�񼤹�ģʽ\n");
            fprintf(obj.fid_, "G55 ;;�����ӡѡ��G55����ϵ\n");
            fprintf(obj.fid_, "G49 ;;�ر�T0�ĳ��Ȳ���\n");
            fprintf(obj.fid_, "M142 ;;����ģ��������\n");   
            obj.curMode_ = 1;            
            ret = 1;
        end        
        
        function ret = enableLaser(obj, powderMode, delay)
        % powerTurnOnMode = 0, close all; 1 = left powder, 2 = right, 3 = left + right;
        % delay: delay time, unit is second.
            fprintf(obj.fid_, "M351P610 ;;�����۸�ͷλ�õ���(�����ش���)\n");
            if(powderMode == 1)
                fprintf(obj.fid_, "M351P602 ;;������·�ͷ�\n");
            end
            if(powderMode == 2)
                fprintf(obj.fid_, ";M351P604 ;;������·�ͷۣ��ݲ�ʹ��\n");
            end
            if(powderMode == 3)
                fprintf(obj.fid_, ";M351P606 ;;��������·�ͷۣ��ݲ�ʹ��\n");
            end
            
            fprintf(obj.fid_, "G04X%d ;;��ʱ10�룬�ȴ�����\n", delay);
            fprintf(obj.fid_, "M351P600 ;;��������\n");     
            fprintf(obj.fid_, ";;;;;;;;;;;;;;;;;;;;;;;;;;;�˶�����ʼ\n");                 
            ret = 1;
        end       
        
        function ret = disableLaser(obj, powderMode)
        % powerTurnOnMode = 0, close all powder; 1 = close left poweder, 2 = right, 3 = left + right;
            fprintf(obj.fid_, ";;;;;;;;;;;;;;;;;;;;;;;;;;;�˶��������\n");
            fprintf(obj.fid_, "M351P601 ;;�رռ���\n");
            fprintf(obj.fid_, "M351P611 ;;�ر��۸�ͷλ�õ���\n");     
            
            if(powderMode == 1)
                fprintf(obj.fid_, "M351P603 ;;�ر���·�ͷ�\n");
            end
            if(powderMode == 2)
                fprintf(obj.fid_, ";M351P605 ;;�ر���·�ͷۣ��ݲ�ʹ��\n");
            end
            if(powderMode == 3)
                fprintf(obj.fid_, ";M351P607 ;;�ر�����·�ͷۣ��ݲ�ʹ��\n");
            end        
            ret = 1;
        end              
        
        function ret = setLaser(obj, pwr, lenPos, flowL, speedL, flowR, speedR)
            fprintf(obj.fid_, "G01 I%d J%d V%d K%d W%d U%d\n", pwr, lenPos, flowL, speedL, flowR, speedR);     
            ret = 1;
        end 
        
        function ret = addCmd(obj, cmd)
            fprintf(obj.fid_, "%s\n",cmd);     
            ret = 1;
        end    
        
        function ret = saftyToStart(obj, safetyPath, feedrate)
            % safetyPath is a 3*3 array, with its cols are xyz 
            if(isnan( sum(safetyPath(1,:)) ))
                fprintf(obj.fid_, "G01 Z%.3f F%d\n", safetyPath(1,3), feedrate);  
            else
                fprintf(obj.fid_, "G01 X%.3f Y%.3f Z%.3f F%d\n", safetyPath(1,1), ...
                    safetyPath(1,2), safetyPath(1,3), feedrate);  
            end
            fprintf(obj.fid_, "G01 X%.3f Y%.3f Z%.3f F%d\n", safetyPath(1,1), ...
                safetyPath(1,2), safetyPath(1,3), feedrate);  
            fprintf(obj.fid_, "G01 X%.3f Y%.3f Z%.3f F%d\n", safetyPath(1,1), ...
                safetyPath(1,2), safetyPath(1,3), feedrate);                  
        end

        function ret = saftyToPt(obj, pt1, ptDst, feedrate)
            % pt1 is the pt in safety area, pt2 is the dst pt in safety area,
            if(isnan( sum(pt1(1,:)) ))
                fprintf(obj.fid_, "G01 Z%.3f F%d\n", pt1(3), feedrate);  
            else
                fprintf(obj.fid_, "G01 X%.3f Y%.3f Z%.3f F%d\n", pt1(1), ...
                    pt1(2), pt1(3), feedrate);  
            end
            fprintf(obj.fid_, "G01 X%.3f Y%.3f Z%.3f F%d\n", ptDst(1), ...
                ptDst(2), pt1(3), feedrate);  
            fprintf(obj.fid_, "G01 X%.3f Y%.3f Z%.3f F%d\n", ptDst(1), ...
                ptDst(2), ptDst(3), feedrate);                 
        end        
        
        function ret = addPathPt(obj, pt)
            fprintf(obj.fid_, "G01 X%.3f Y%.3f Z%.3f\n", pt(1), pt(2), pt(3));  
        end
        function ret = addPathPtFeed(obj, pt, feedrate)
            fprintf(obj.fid_, "G01 X%.3f Y%.3f Z%.3f F%d\n", pt(1), pt(2), pt(3), feedrate);  
        end
        
        function ret = addPathPts(obj, pts, feedrate)
            fprintf(obj.fid_, "G01 X%.3f Y%.3f Z%.3f F%d\n", pts(1,1), pts(1,2), pts(1,3), feedrate);  
            for i = 2:length(pts)
                obj.addPathPt(pts(i,:));
            end
        end
                        
        
    end
end

