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
    fprintf(obj.fid_,  "M7 ;;�ŵ�\r\n");
    fprintf(obj.fid_,  "G49 ;;�ر�T0�ĳ��Ȳ���\r\n" );     
    ret = 1;
    return;
   end
    fprintf(obj.fid_, "T%dM6 ;;ѡ��ȡ��\r\n", toolNum);     
    fprintf(obj.fid_, "G43H%d ;;������\r\n", toolNum);                 
    ret = 1;            
end % changeTool(obj, toolNum)