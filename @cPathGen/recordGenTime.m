function ret = recordGenTime(obj)
% create the nc file     
    timeStr = datestr(datetime, 'yyyy.mm.dd - HH:MM:SS');
    fprintf(obj.fid_, ";;;;;;;;;;;;;generate Time: %s ;;;;;;;;\r\n", timeStr);
    ret = 1;
end % openFile(obj)   