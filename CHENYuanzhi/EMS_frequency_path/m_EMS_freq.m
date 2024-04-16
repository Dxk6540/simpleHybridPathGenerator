clear;clc;
%% Symbol function
syms f t;
EMS_sym=symfun(-100/60*cos(2*pi*f*t)+700/60,[f,t]);
% d_sym=100/60/(2*pi*f)*sin(2*pi*f*t)+700/60*t;
d_sym=int(EMS_sym,t);
EMS_numeric=matlabFunction(EMS_sym);
d_numeric=matlabFunction(d_sym);

tSeq=(0:0.0001:100)';
fList=[0.1,0.2,0.4,0.6,0.8,1,3,5,7.048]';
xList=(-30:7.5:30)';
total_posSeq=[];
total_vSeq=[];
for i=1:length(xList)
    f_=fList(i);
    EMS=EMS_numeric(f_,tSeq);
    d= d_numeric(f_, tSeq);
    tvd=[tSeq,EMS,d];
    [dSeq,vSeq] = tvd_dv(tvd,0.005,65,false);
    dSeq=dSeq+(-30);
    dSeq=[-35;dSeq];
    vSeq=[10;vSeq];
    posSeq=ones(length(dSeq),3);
    x_=xList(i);
    posSeq(:,1)=posSeq(:,1)*x_;
    posSeq(:,2)=dSeq;
    posSeq(:,3)=0;
    total_posSeq=[total_posSeq;posSeq];
    total_vSeq=[total_vSeq;vSeq];
end
pPathSeq=total_posSeq;
feedSeq=total_vSeq;
clear total_posSeq total_vSeq dSeq x_ f_ i t d d_numeric EMS EMS_numeric EMS_sym d_sym; 
%% Create the path
EDR=90;
pwrSeq=EDR*feedSeq;
pwrSeq(pPathSeq(:,2)>34.995)=0;
pwrSeq(pPathSeq(:,2)<-34.995)=0;
pwrSeq=pwrSeq/4;
feedSeq=feedSeq*60;
%% G55 AM coordinate system, G49 No tool compensation!
name='consEDR_EMS_varyingFrequency';
fid=fopen([name,'.NC'],'wt');
camPos=[-105,-5,115];
%% probe initialization'
fprintf(fid,';;;;----------------print initialization----------------;;;;\n');
initialPrint=[
    'M64  ;;open the door\n'...
    'M66  ;;close the door\n'...
    'M94 ;;Z2 axis\n'...
    'G55 ;;AM coordinate system\n'...
    'G49 ;;close the tool compensation\n'...
    'G43H16 ;;open the laser probe compensation\n'...
    'M142 ;;turn on analog interpolation\n'...
    'M146 I300 J900 V250 K100 W250 U100\n'...
    'G01 Z220.000 F3000.000\n'];
fprintf(fid,initialPrint);
%% choose to rotate the substrate
C0=false;
if(C0)
    fprintf(fid,'G01 B0 C0 F3000 ;; Attention: B0 C0\n');
else
    fprintf(fid,'G01 B0 C45 F3000 ;; Attention: B0 C45\n');
end
%% Store the path points
fid2=fopen([name,'_Info.txt'],'wt');
for i=1:size(pPathSeq,1)
    fprintf(fid2,'%.4f,%.4f,%.4f,%.4f,%.4f\n',pPathSeq(i,1),pPathSeq(i,2),pPathSeq(i,3),pwrSeq(i),feedSeq(i));
end
fclose(fid2);
%% generate printing Gcodes
preparePrinting=[';;;;----------------start printing----------------;;;;\n'...
    sprintf('G01 X%.4f Y%.4f Z220 F3000.000\n', pPathSeq(1,1), pPathSeq(1,2))...
    sprintf('G01 X%.4f Y%.4f Z%.4f F3000.000\n', pPathSeq(1,1),pPathSeq(1,2),pPathSeq(1,3))...
    'M351P610  ;;开启熔覆头位置调整(上升沿触发)\n'...
    'M351P602  ;;开启左路送粉\n'...
    'G04X20 ;;延时20秒，等待出粉\n'...
    'M351P600 ;;开启激光\n'];
fprintf(fid,preparePrinting);
for i=1:size(pPathSeq,1)
    fprintf(fid,'G01 X%.4f Y%.4f Z%.4f I%.4f J900 F%.4f\n',pPathSeq(i,1),pPathSeq(i,2),pPathSeq(i,3), pwrSeq(i),feedSeq(i));
end
%% end printing
endPrinting=[';;;;----------------end printing----------------;;;;\n'...
    'M351P601 ;;关闭激光\n'...
    'M351P611 ;;关闭熔覆头位置调整\n'...
    'M351P603 ;;关闭左路送粉\n'...
    'G01 Z220.000 F3000\n'];
fprintf(fid,endPrinting);
%% detect
detectCode=[';;;;----------------detect----------------;;;;\n'...
    sprintf('G01 X%.4f Y%.4f Z%.4f F3000;;\n',camPos(1),camPos(2),camPos(3))...
    'M0\n'...
    'M63  ;;close the door\n'...
    'M65  ;;open the door\n'...
    'M30  ;;end program\n'];
fprintf(fid,detectCode);
fclose(fid);
% %% display the path
% %%%%%%% move path
% figure('Name','move path')
% axis equal;
% plot3(pPathSeq(:,1),pPathSeq(:,2),pPathSeq(:,3));
% axis equal;
% %%%%%%% power path
% pwrPts={};
% pts=pPathSeq(1,:);
% lastPwr=pwrSeq(1);
% j=0;
% for i=2:length(pwrSeq)
%     if pwrSeq(i)==lastPwr
%         pts=[pts;pPathSeq(i,:)];
%     else
%         if size(pts,1)>1
%             j=j+1;
%             pwrPts{j}=pts;
%         end
%         pts=pPathSeq(i-1,:);
%         pts=[pts;pPathSeq(i,:)];
%         lastPwr=pwrSeq(i);
%     end
% end
% if size(pts,1)>1
%     j=j+1;
%     pwrPts{j}=pts;
% end
% figure('Name','power path')
% axis equal;
% rotate3d;
% for i=1:length(pwrPts)
%     plot3(pwrPts{i}(:,1),pwrPts{i}(:,2),pwrPts{i}(:,3),'LineWidth',3,'Color',rand(1,3));
%     hold on;
% end
% xlabel('X');% x轴名称
% ylabel('Y');
% %% EMS path
% speedPts={};
% pts=pPathSeq(1,:);
% lastSpeed=feedSeq(1);
% j=0;
% for i=2:length(feedSeq)
%     if feedSeq(i)==lastSpeed
%         pts=[pts;pPathSeq(i,:)];
%     else
%         if size(pts,1)>1
%             j=j+1;
%             speedPts{j}=pts;
%         end
%         pts=pPathSeq(i-1,:);
%         pts=[pts;pPathSeq(i,:)];
%         lastSpeed=feedSeq(i);
%     end
% end
% if size(pts,1)>1
%     j=j+1;
%     speedPts{j}=pts;
% end
% figure('Name','feedrate path')
% axis equal;
% rotate3d;
% for i=1:length(speedPts)
%     plot3(speedPts{i}(:,1),speedPts{i}(:,2),speedPts{i}(:,3),'LineWidth',3,'Color',rand(1,3));
%     hold on;
% end
% xlabel('x [mm]','FontSize',12,'FontName','Times New Roman','Color','k');
% ylabel('y [mm]','FontSize',12,'FontName','Times New Roman','Color','k');