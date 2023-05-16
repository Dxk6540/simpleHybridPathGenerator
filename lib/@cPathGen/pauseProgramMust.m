function ret = pauseProgramMust(obj)
    fprintf(obj.fid_, "M00 ;;程序暂停，按启动重新启动\r\n");
    ret = 1;
end