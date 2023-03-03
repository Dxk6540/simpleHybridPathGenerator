function ret = machiningMode(obj)
    fprintf(obj.fid_, "M93 ;;选择主轴模式\r\n");
    fprintf(obj.fid_, "M143 ;;关闭模拟量插补\r\n");
    fprintf(obj.fid_, "G54 ;;主轴选择G54坐标系\r\n");
    obj.curMode_ = 2;            
    ret = 1;
end % machiningMode(obj)   