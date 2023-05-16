function ret = openFile(obj)
% create the nc file              
    obj.fid_ = fopen(obj.filename_, 'w+');
    ret = 1;
end % openFile(obj)   



