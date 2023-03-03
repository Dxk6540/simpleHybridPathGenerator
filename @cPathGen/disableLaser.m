function ret = disableLaser(obj, powderMode)
% powerTurnOnMode = 0, close all powder; 1 = close left poweder, 2 = right, 3 = left + right;
    fprintf(obj.fid_, ";;;;;;;;;;;;;;;;;;;;;;;;;;;运动程序结束\r\n");
    fprintf(obj.fid_, "M351P601 ;;关闭激光\r\n");
    fprintf(obj.fid_, "M351P611 ;;关闭熔覆头位置调整\r\n");     

    if(powderMode == 1)
        fprintf(obj.fid_, "M351P603 ;;关闭左路送粉\r\n");
    end
    if(powderMode == 2)
        fprintf(obj.fid_, "M351P605 ;;关闭右路送粉，暂不使用\r\n");
    end
    if(powderMode == 3)
        fprintf(obj.fid_, "M351P607 ;;关闭左右路送粉，暂不使用\r\n");
    end        
    ret = 1;
end  % disableLaser(obj, powderMode)       