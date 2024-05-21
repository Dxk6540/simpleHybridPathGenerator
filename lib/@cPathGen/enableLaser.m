function ret = enableLaser(obj, powderMode, delay)
% powerTurnOnMode = 0, close all; 1 = left powder, 2 = right, 3 = left + right;
% delay: delay time, unit is second.
    fprintf(obj.fid_, "M351P610  ;;�����۸�ͷλ�õ���(�����ش���)\r\n");
    if(powderMode == 0)
%         fprintf(obj.fid_, "M351P602  ;;������·�ͷ�\r\n"); % no powder
    end
    if(powderMode == 1)
        fprintf(obj.fid_, "M351P602  ;;������·�ͷ�\r\n");
    end
    if(powderMode == 2)
        fprintf(obj.fid_, "M351P604  ;;������·�ͷۣ��ݲ�ʹ��\r\n");
    end
    if(powderMode == 3)
        fprintf(obj.fid_, "M351P606  ;;��������·�ͷۣ��ݲ�ʹ��\r\n");
    end

    fprintf(obj.fid_, "G04X%d ;;��ʱ10�룬�ȴ�����\r\n", delay);
    fprintf(obj.fid_, "M351P600 ;;��������\r\n");     
    fprintf(obj.fid_, ";;;;;;;;;;;;;;;;;;;;;;;;;;;�˶�����ʼ\r\n");                 
    ret = 1;
end  % enableLaser(obj, powderMode, delay)     
