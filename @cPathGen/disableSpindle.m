function ret = disableSpindle(obj)
    fprintf(obj.fid_, ";;;;;;;;;;;;;;;;;;;;;;;;;;;�˶��������\r\n");
    fprintf(obj.fid_,  "M70 ;;�ش���\r\n");
    fprintf(obj.fid_, "M05;;������\r\n");     

    ret = 1;
end  % disableSpindle(obj)   