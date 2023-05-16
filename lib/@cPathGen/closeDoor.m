function ret = closeDoor(obj)
% close the door of the machine tool            
    fprintf(obj.fid_, "M64  ;;关侧门\r\n");
    fprintf(obj.fid_, "M66  ;;关主门\r\n");
    ret = 1;
end % closeDoor(obj)