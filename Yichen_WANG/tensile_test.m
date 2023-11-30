%%%%%%%%%%%%%%%%%%%
%
% date: 2023-4-24
% author: CHEN Yuanzhi
%
%%%%%%%%%%%%%%%%%%

% file param:
hFilename = strcat('./tensileTest',date,'.txt');

% printing process param
pwr = 210;
pFeedrate = 625; % mm/min
lenPos = 900;
flowL = 250; % 6 L/min / 20L/min * 1000;
speedL = 100;% 2 r/min / 10r/min * 1000;
flowR = 400;% 6 L/min / 20L/min * 1000;
speedR = 100;% 2 r/min / 10r/min * 1000;
step = 0.8;
angle = 0; 
% angle=0;
tilte=0;
startCtr = [0,0];
pLyrNum = 230;
lyrHeight = 0.5;
cubeShape = [15,20];

% machining process param
mFeedrate = 2000; % mm/min
spindleSpeed = 8000;
toolNum = 3;
toolRadiu = 4;
machiningLyrThickness = 0.1;

%  geometry param
tol = 0.01;
safetyHeight = min(230, 2*pLyrNum*lyrHeight+20);
zOffset = 0;

rotation = false;
ammode = 0;
aus=true;
amode=0;
side = 1; % machining inside is -1 and outside is 1
wallOffset = 0.3;
allPath=[];
ausPath=[];
masPath=[];
% shape
handle = rotationalZigzagPathCube;

%%
%%%%%%%%%%%%%% printing path
%%%% the regular code for generate a script
pg = cPathGen(hFilename); % create the path generator object
pg.genNewScript();
pg.changeMode(1); % change to printing mode
[pPathSeq,bcSeq,pwrSeq,feedOffset] = handle.genPrintingPath(cubeShape, startCtr, pLyrNum, lyrHeight, pwr, zOffset, angle, false, tilte, step, aus, ammode);
lenPosSeq = ones(length(pPathSeq),1) * lenPos;
%%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%
%%% start printing mode
pg.setLaser(0, lenPos, flowL, aus*speedL, flowR, (~aus)*speedR); % set a init process param (in case of overshoot)
pg.saftyToPt([nan, nan, safetyHeight], pPathSeq(1,:), 3000); % safety move the start pt
pg.pauseProgram();% pause and wait for start (the button)
pg.enableLaser(1, 10);
%%% add path pts
pg.addPathPtsWithPwr(pPathSeq, pwrSeq, lenPosSeq, pFeedrate*feedOffset);
%%% exist printing mode
pg.disableLaser(3);
pg.draw_ = true;
pg.drawPath(pPathSeq,pPathSeq);
