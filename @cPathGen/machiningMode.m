function ret = machiningMode(obj)
    fprintf(obj.fid_, "M93 ;;ѡ������ģʽ\r\n");
    fprintf(obj.fid_, "M143 ;;�ر�ģ�����岹\r\n");
    fprintf(obj.fid_, "G54 ;;����ѡ��G54����ϵ\r\n");
    obj.curMode_ = 2;            
    ret = 1;
end % machiningMode(obj)   