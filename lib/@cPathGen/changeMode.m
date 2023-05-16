function ret = changeMode(obj, mode)
% 0 is idle, 1 is printing, 2 machining
    if(mode == 1)
        obj.printingMode();
        ret = 1;
        return;
    end

    if(mode == 2)
        obj.machiningMode();
        ret = 1;
        return;
    end                                    
    ret = 0;
end % changeMode(obj, mode)