function ret = endProgram(obj)
    fprintf(obj.fid_, "M30  ;; end program.\r\n");
    ret = 1;
end % endProgram(obj)