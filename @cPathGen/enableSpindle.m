function ret = enableSpindle(obj, spindleSpeed, wcsPath)
%      fprintf(obj.fid_, "T1M6 ;;ѡ��ȡ��\r\n");
    fprintf(obj.fid_, "S%dM3 ;;��������\r\n", spindleSpeed);     
    fprintf(obj.fid_, "G04X5 ;;�ȴ�����ﵽĿ��ת��\r\n");               
%     fprintf(obj.fid_, "G43H1 ;;������\r\n");   
    fprintf(obj.fid_, "M69 ;;������\r\n");               
    fprintf(obj.fid_, ";;;;;;;;;;;;;;;;;;;;;;;;;;;�˶�����ʼ\r\n");               
    ret = 1;
end  % enableSpindle(obj, spindleSpeed, wcsPath)   