function ret = changePowder(obj, flowL, speedL, flowR, speedR, delay)
   if(obj.curMode_ ~= 1)
       disp("changePowder() err! current mode is not printing mode!");
       ret = 0;
       return;
   end
    fprintf(obj.fid_, "G01 I0 V%d K%d W%d U%d\r\n", flowL, speedL, flowR, speedR); 
    if delay > 0
        fprintf(obj.fid_, "G04X%d ;;—” ±\r\n", delay);  
    end             
    ret = 1;            
end % changeTool(obj, toolNum)