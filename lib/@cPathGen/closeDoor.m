function ret = closeDoor(obj)
% close the door of the machine tool            
    fprintf(obj.fid_, "M64  ;;�ز���\r\n");
    fprintf(obj.fid_, "M66  ;;������\r\n");
    ret = 1;
end % closeDoor(obj)