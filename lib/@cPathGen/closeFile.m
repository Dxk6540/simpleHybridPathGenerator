function ret = closeFile(obj)
    fclose(obj.fid_);
    ret = 1;
end % closeFile(obj)  