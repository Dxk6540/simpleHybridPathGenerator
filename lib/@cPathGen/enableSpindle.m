function ret = enableSpindle(obj, spindleSpeed, wcsPath)
%      fprintf(obj.fid_, "T1M6 ;;选刀取刀\r\n");
    fprintf(obj.fid_, "S%dM3 ;;启动主轴\r\n", spindleSpeed);     
    fprintf(obj.fid_, "G04X5 ;;等待主轴达到目标转速\r\n");               
%     fprintf(obj.fid_, "G43H1 ;;开刀补\r\n");   
    fprintf(obj.fid_, "M69 ;;开吹气\r\n");               
    fprintf(obj.fid_, ";;;;;;;;;;;;;;;;;;;;;;;;;;;运动程序开始\r\n");               
    ret = 1;
end  % enableSpindle(obj, spindleSpeed, wcsPath)   