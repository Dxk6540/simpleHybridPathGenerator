function ret = pauseProgramMust(obj)
    fprintf(obj.fid_, "M00 ;;������ͣ����������������\r\n");
    ret = 1;
end