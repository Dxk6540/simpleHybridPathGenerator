% this is an example of generate machining process
close all
% file param:
pFilename = strcat('./zichuan',date,'.txt');

hProc = cHybridProcess(pFilename);
hProc.sMachinParam_.spindleSpeed = 8000; % mm/min
hProc.sMachinParam_.mFeedrate = 2000; % both powder are used
hProc.sMachinParam_.toolNum = 3;
hProc.sMachinParam_.toolRadiu = 5;
hProc.sPrintParam_.pFeedrate = 700; % mm/min
hProc.sPrintParam_.powderMode = 2; % left powder are used
hProc.sPrintParam_.pwr = 300; % left powder are used

%  geometry param
startPoint = [-30,-10]; % left corner
wpHeight = pLyrNum * lyrHeight;
machiningLyrThickness = -0.1;
channel = 6;
startX = startPoint(1); %起点X坐标
startY = startPoint(2); %起点Y坐标
cubeLen = 60; %单线长度
step = 2.5; % 搭接
height = 0.3; %层高
count = 5; %层数
Path=[]; %路径


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

feedrate = 700;


pPathSeq = Path;

%%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%
%%%% the regular code for generate a script
pg = cPathGen(pFilename); % create the path generator object
pg.genNewScript();
pg.draw_ = true;

hProc.genNormalPrintingProcess(pg, pPathSeq, pwrSeq, hProc.sPrintParam_.pFeedrate, hProc.sPrintParam_);


pg.closeScript();
