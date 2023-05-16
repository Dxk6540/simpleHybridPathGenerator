function ret = openDoor(obj)
% open the door of the machine tool
    fprintf(obj.fid_, "M63  ;;开侧门\r\n");
    fprintf(obj.fid_, "M65  ;;开主门\r\n");
    ret = 1;
end % openDoor(obj)