function ret = pauseProgram(obj)
    if obj.experiment_
        fprintf(obj.fid_, "M00 ;;程序暂停，按启动重新启动\r\n");
    end
    ret = 1;
end % pauseProgram(obj)