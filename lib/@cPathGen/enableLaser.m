function ret = enableLaser(obj, powderMode, delay)
% powerTurnOnMode = 0, close all; 1 = left powder, 2 = right, 3 = left + right;
% delay: delay time, unit is second.
    fprintf(obj.fid_, "M351P610  ;;开启熔覆头位置调整(上升沿触发)\r\n");
    if(powderMode == 0)
%         fprintf(obj.fid_, "M351P602  ;;开启左路送粉\r\n"); % no powder
    end
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
