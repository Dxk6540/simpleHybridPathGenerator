function ret = printingMode(obj)
% printing mode along with G55 CS + update AIO
    fprintf(obj.fid_, "M94 ;;ѡ�񼤹�ģʽ\r\n");
    fprintf(obj.fid_, "G55 ;; �����ӡѡ��G55����ϵ\r\n");
    fprintf(obj.fid_, "G49  ;;�ر�T0�ĳ��Ȳ���\r\n");
    fprintf(obj.fid_, "M142 ;;����ģ�����岹\r\n");                 
    obj.curMode_ = 1;            
    ret = 1;
end % printingMode(obj)    