function ret = pauseProgram(obj)
    if obj.experiment_
        fprintf(obj.fid_, "M00 ;;������ͣ����������������\r\n");
    end
    ret = 1;
end % pauseProgram(obj)