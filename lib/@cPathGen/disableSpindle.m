function ret = disableSpindle(obj)
    fprintf(obj.fid_, ";;;;;;;;;;;;;;;;;;;;;;;;;;;运动程序结束\r\n");
    fprintf(obj.fid_,  "M70 ;;关吹气\r\n");
    fprintf(obj.fid_, "M05;;关主轴\r\n");     

    ret = 1;
end  % disableSpindle(obj)   