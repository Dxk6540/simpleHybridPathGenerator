function ret = genNewScript(obj)
    ret = obj.openFile();  % open the file
    if ret == 0
        disp('err in open file! maybe already opened!');
    end
    obj.recordGenTime();
    obj.closeDoor(); % close door
    ret = 1;
end % closeDoor(obj)