%% G55 AM coordinate system, G49 No tool compensation!
clear;clc;
addpath('./1_resources');
addpath('./2_results');
addpath('./interpolation');
load 24052104_channelPts_1;

resultsPath='./2_results';
expIndex=24052104;
fileName=strcat(num2str(expIndex),'_Gcodes_1');
filePath=fullfile(resultsPath,fileName);
fid=fopen([filePath,'.NC'],'wt');
camPos=[-110,-10,120];
%% powder mode
powderMode=3; %0-no, 1-left, 2-right, 3-left and right
powderDelay=10;
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
    'G01 Z220.000 F3000.000\n'];
fprintf(fid,initialPrint);
%% choose to rotate the substrate
C0=false;
if(C0)
    fprintf(fid,'G01 B0 C0 F3000 ;; Attention: B0 C0\n');
else
    fprintf(fid,'G01 B0 C45 F3000 ;; Attention: B0 C45\n');
end
%% generate the path pts
Zoffset=0;
pPathSeq=pathSeq(:,1:3);
pPathSeq(:,3)=pPathSeq(:,3)+Zoffset;
EDRSeq=pathSeq(:,4);
feedSeq=pathSeq(:,5);
if(size(pathSeq,2)==7) %% if mix powder
    powderRatios=pathSeq(:,6:7);
else
    powderRatios=zeros(size(pPathSeq,1),2);
end
%% Interpolation
i=2;
while i<=size(pPathSeq,1)
    if abs(feedSeq(i)-feedSeq(i-1))>0.001 %feed rate changes
        pos_v=[pPathSeq(i-1:i,:),feedSeq(i-1:i)];
        EDR=EDRSeq(i);
        powderRatio=powderRatios(i,:);
        [t_v_pos_d_seq,interpPathSeq,interpFeedSeq,acc,pos_v_d_seq]=interpolateBetweenTwoPos(pos_v,100,true,false,false);
        interpEDRSeq=EDR*ones(length(interpFeedSeq),1);
        interpPowderModes=ones(length(interpFeedSeq),1)*powderRatio;
        pPathSeq=[pPathSeq(1:i-1,:);interpPathSeq(2:end-1,:);pPathSeq(i:end,:)];
        feedSeq=[feedSeq(1:i-1);interpFeedSeq(2:end-1);feedSeq(i:end)];
        EDRSeq=[EDRSeq(1:i-1);interpEDRSeq(2:end-1);EDRSeq(i:end)];
        powderRatios=[powderRatios(1:i-1,:);interpPowderModes(2:end-1,:);powderRatios(i:end,:)];
        i=i+size(interpFeedSeq,1)-2;
    end
    i=i+1;
end
temp=[pPathSeq,EDRSeq,feedSeq];
%% Store the path points
fid2=fopen([filePath,'_Info.txt'],'wt');
channelIndex=0;
for i=1:size(pPathSeq,1)
    fprintf(fid2,'%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f\n',pPathSeq(i,1),pPathSeq(i,2),pPathSeq(i,3),EDRSeq(i),feedSeq(i),powderRatios(i,1),powderRatios(i,2));
end
fclose(fid2);
%% generate printing Gcodes
pwrSeq=EDRSeq.*feedSeq./4;
feedSeq=feedSeq*60;
powderRatios=powderRatios.*100;
preparePrinting=[';;;;----------------start printing----------------;;;;\n'...
    sprintf('M146 I300 J900 V250 K%.4f W400 U%.4f\n',powderRatios(1,1),powderRatios(1,2))...
    sprintf('G01 X%.4f Y%.4f Z220 F3000.000\n', pPathSeq(1,1), pPathSeq(1,2))...
    sprintf('G01 X%.4f Y%.4f Z%.4f F3000.000\n', pPathSeq(1,1),pPathSeq(1,2),pPathSeq(1,3))...
    'M351P610  ;;开启熔覆头位置调整(上升沿触发)\n'];
switch(powderMode)
    case 0
        preparePrinting=strcat(preparePrinting, ...
            'M351P600 ;;开启激光\n');
    case 1
        preparePrinting=strcat(preparePrinting, ...
            'M351P602  ;;开启左路送粉\n',... %% 分 和为1r
            'G04X',num2str(powderDelay),'  ;;延时，等待出粉\n',...
            'M351P600 ;;开启激光\n');
    case 2
        preparePrinting=strcat(preparePrinting, ...
            'M351P604  ;;开启右路送粉\n',... %% 分 和为1r
            'G04X',num2str(powderDelay),'  ;;延时，等待出粉\n',...
            'M351P600 ;;开启激光\n');
    case 3
        preparePrinting=strcat(preparePrinting, ...
            'M351P606  ;;开启左右路送粉\n',... %% 分 和为1r
            'G04X',num2str(powderDelay),'  ;;延时，等待出粉\n',...
            'M351P600 ;;开启激光\n');
end
fprintf(fid,preparePrinting);
switch(powderMode)
    case 3
        for i=1:size(pPathSeq,1)
            fprintf(fid,'G01 X%.4f Y%.4f Z%.4f I%.4f J900 F%.4f K%.4f U%.4f\n',pPathSeq(i,1),pPathSeq(i,2),pPathSeq(i,3), pwrSeq(i),feedSeq(i),powderRatios(i,1),powderRatios(i,2));
            if i<size(pPathSeq,1)
                if abs(pPathSeq(i+1,1)-pPathSeq(i,1))>4
                    channelIndex=channelIndex+1;
                    fprintf(fid,';;;;;;;;;; Channel index: %d\n',channelIndex);
                end
            end
        end
    otherwise
        for i=1:size(pPathSeq,1)
            fprintf(fid,'G01 X%.4f Y%.4f Z%.4f I%.4f J900 F%.4f\n',pPathSeq(i,1),pPathSeq(i,2),pPathSeq(i,3), pwrSeq(i),feedSeq(i));
            if i<size(pPathSeq,1)
                if abs(pPathSeq(i+1,1)-pPathSeq(i,1))>4
                    channelIndex=channelIndex+1;
                    fprintf(fid,';;;;;;;;;; Channel index: %d\n',channelIndex);
                end
            end
        end
end
%% end printing
endPrinting=[';;;;----------------end printing----------------;;;;\n'...
    'M351P601 ;;关闭激光\n'...
    'M351P611 ;;关闭熔覆头位置调整\n'];
%% Close the powder
switch(powderMode)
    case 0

    case 1
        endPrinting=strcat(endPrinting, ...
            'M351P603 ;;关闭左路送粉\n');
    case 2
        endPrinting=strcat(endPrinting, ...
            'M351P605  ;;关闭右路送粉\n');
    case 3
        endPrinting=strcat(endPrinting, ...
            'M351P607  ;;关闭左右路送粉\n');
end
endPrinting=strcat(endPrinting,'G01 Z230.000 F3000\n');
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