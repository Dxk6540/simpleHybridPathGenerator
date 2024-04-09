%%%%%%%%%%%%%%%%%%%
%
% date: 2023-5-15
% author: CHEN Yuanzhi
%
%%%%%%%%%%%%%%%%%%

% file param:
hFilename = strcat('./inclinePrintedBlock',date,'.txt');

% printing process param
pwr = 160; % 1.2KW / 4kw *1000;
lenPos = 900;
flowL = 250; % 6 L/min / 20L/min * 1000;
speedL = 100;% 2 r/min / 10r/min * 1000;
flowR = 400;% 6 L/min / 20L/min * 1000;
speedR = 100;% 2 r/min / 10r/min * 1000;
pFeedrate = 500; % mm/min
step = 0.8;
safetyHeight = 25;
traverse=2000;

%  geometry param
startCtr = [-77.5,-70];
pLyrNum = 40;
lyrHeight = 0.5;
wallLength = 15;
clearanceX=15;
clearanceY=30;
lead = 5;
inclineAngle = 0;
leanAngle=7;
channel = 6;
offset=1;
% shape
handle = inclinePrintedBlock;

%%
%%%%%%%%%%%%%% printing path
%%%% the regular code for generate a script
pg = cPathGen(hFilename); % create the path generator object
pg.genNewScript();
totalPath=[];
startCtrTmp=startCtr;
for inclineAngle = 0:5:45
    pg.changeMode(1); % change to printing mode
    [pPathSeq,pwrSeq,pFeedrateSeq] = handle.genPrintingPath(wallLength, startCtrTmp, lead, pLyrNum, lyrHeight, pwr, inclineAngle, channel, step, leanAngle, pFeedrate, traverse, offset);
    lenPosSeq = ones(length(pPathSeq),1) * lenPos;
    %%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%
    %%% start printing mode
    pg.setLaser(0, lenPos, flowL, speedL, flowR, speedR); % set a init process param (in case of overshoot)
    pg.addPathPts([0,0,safetyHeight,inclineAngle,0], 3000);
    pg.startRTCP(safetyHeight, 16);
    pg.saftyToPt([nan, nan, safetyHeight], pPathSeq(1,:), 3000); % safety move the start pt
    pg.enableLaser(1, 5);
    %%% add path pts
    pg.addPathPtsWithPwr(pPathSeq, pwrSeq, lenPosSeq, pFeedrateSeq);
    %%% exist printing mode
    pg.disableLaser(1);
    pg.stopRTCP(200, 16);
    totalPath=[totalPath;pPathSeq];
    startCtrTmp(1)= startCtrTmp(1)+clearanceX;
 end
pg.draw_ = true;
pg.drawPath(totalPath, totalPath);
%% end the script
pg.closeScript();

