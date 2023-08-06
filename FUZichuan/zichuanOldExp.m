% this is an example of generate machining process
clc; clear all;
close all
% file param:
pFilename = strcat('./zichuan',date,'.txt');

hProc = cHybridProcess(pFilename);
hProc.sMachinParam_.spindleSpeed = 8000; % mm/min
hProc.sMachinParam_.mFeedrate = 2000; % both powder are used
hProc.sMachinParam_.toolNum = 3;
hProc.sMachinParam_.toolRadiu = 5;
hProc.sPrintParam_.pFeedrate = 700; % mm/min
hProc.sPrintParam_.powderMode = 1; % left powder are used
hProc.sPrintParam_.pwr = 250; % left powder are used


%  geometry param
height = 0.5; %���
count = 20; %����
startPoint = [-15,80]; % left corner
wpHeight = count * height;
machiningLyrThickness = -0.1;
channel = 2;
startX = startPoint(1); %���X����
startY = startPoint(2); %���Y����
cubeLen = 30; %���߳���
step = 1.5; % ���

Path=[]; %·��


for i = 0:count 
    Temp=[startX,startY,height*i;
        startX+cubeLen,startY,height*i];
    Path=[Path;Temp];
    if (step>0)
        Temp=flipud(Temp);
        Path=[Path;[0,step,0]+Temp];
    end

end
pwrSeq = ones(length(Path),1) * hProc.sPrintParam_.pwr;
lenPos = ones(length(Path),1) * hProc.sPrintParam_.lenPos;


pPathSeq = Path;

%%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%
%%%% the regular code for generate a script
pg = cPathGen(pFilename); % create the path generator object
pg.genNewScript();
pg.draw_ = true;
pg.drawPath(Path, Path);
hProc.genNormalPrintingProcess(pg, pPathSeq, pwrSeq, hProc.sPrintParam_.pFeedrate, hProc.sPrintParam_);

pg.closeScript();
