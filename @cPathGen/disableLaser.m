function ret = disableLaser(obj, powderMode)
% powerTurnOnMode = 0, close all powder; 1 = close left poweder, 2 = right, 3 = left + right;
    fprintf(obj.fid_, ";;;;;;;;;;;;;;;;;;;;;;;;;;;�˶��������\r\n");
    fprintf(obj.fid_, "M351P601 ;;�رռ���\r\n");
    fprintf(obj.fid_, "M351P611 ;;�ر��۸�ͷλ�õ���\r\n");     

    if(powderMode == 1)
        fprintf(obj.fid_, "M351P603 ;;�ر���·�ͷ�\r\n");
    end
    if(powderMode == 2)
        fprintf(obj.fid_, "M351P605 ;;�ر���·�ͷۣ��ݲ�ʹ��\r\n");
    end
    if(powderMode == 3)
        fprintf(obj.fid_, "M351P607 ;;�ر�����·�ͷۣ��ݲ�ʹ��\r\n");
    end        
    ret = 1;
end  % disableLaser(obj, powderMode)       