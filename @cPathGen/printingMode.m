function ret = printingMode(obj)
% printing mode along with G55 CS + update AIO
    fprintf(obj.fid_, "M94 ;;选择激光模式\r\n");
    fprintf(obj.fid_, "G55 ;; 激光打印选择G55坐标系\r\n");
    fprintf(obj.fid_, "G49  ;;关闭T0的长度补偿\r\n");
    fprintf(obj.fid_, "M142 ;;开启模拟量插补\r\n");                 
    obj.curMode_ = 1;            
    ret = 1;
end % printingMode(obj)    