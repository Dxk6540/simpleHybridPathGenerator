function ret = changeTool(obj, toolNum)
   if(obj.curMode_ ~= 2)
       disp("changeTool() err! current mode is not machining mode!");
       ret = 0;
       return;
   end
   if(toolNum < 0 || toolNum > 3)
    disp("changeTool() err! toolNum can't find!")
       ret = 0;
       return;               
   end
   if(toolNum == 0)
    fprintf(obj.fid_,  "M7 ;;放刀\r\n");
    fprintf(obj.fid_,  "G49 ;;关闭T0的长度补偿\r\n" );     
    ret = 1;
    return;
   end
    fprintf(obj.fid_, "T%dM6 ;;选刀取刀\r\n", toolNum);     
    fprintf(obj.fid_, "G43H%d ;;开刀补\r\n", toolNum);                 
    ret = 1;            
end % changeTool(obj, toolNum)