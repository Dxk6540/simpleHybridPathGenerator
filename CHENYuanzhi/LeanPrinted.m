%%%%%%%%%%%%%%%%%%%
%
% date: 2023-5-15
% author: CHEN Yuanzhi
%
%%%%%%%%%%%%%%%%%%

% file param:
hFilename = strcat('./inclinePrintedWall',date,'.txt');

% printing process param
pwr = 170; % 1.2KW / 4kw *1000;
lenPos = 900;
flowL = 250; % 6 L/min / 20L/min * 1000;
speedL = 100;% 2 r/min / 10r/min * 1000;
flowR = 400;% 6 L/min / 20L/min * 1000;
speedR = 100;% 2 r/min / 10r/min * 1000;
pFeedrate = 160; % mm/min
step = 0;
safetyHeight = 25;
traverse=500;

%  geometry param
startCtr = [-80,-65];
pLyrNum = 30;
lyrHeight = 0.5;
wallLength = 15;
clearanceX=15;
clearanceY=60;
lead = 5;
inclineAngle = 0;
leanAngle=5;
channel = 2;
offset=1;
% shape
handle = inclinePrintedWall;

%%
%%%%%%%%%%%%%% printing path
%%%% the regular code for generate a script
pg = cPathGen(hFilename); % create the path generator object
pg.genNewScript();
totalPath=[];
for pFeedrate = 350:30:450
    startCtrTmp = startCtr;
    for inclineAngle = 0:5:55
        pg.changeMode(1); % change to printing mode
        [pPathSeq,pwrSeq,pFeedrateSeq] = handle.genPrintingPath(wallLength, startCtrTmp, lead, pLyrNum, lyrHeight, pwr, inclineAngle, channel, step, leanAngle, pFeedrate, traverse, offset);
        lenPosSeq = ones(length(pPathSeq),1) * lenPos;
        %%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%
        %%% start printing mode
        pg.setLaser(0, lenPos, flowL, speedL, flowR, speedR); % set a init process param (in case of overshoot)
        pg.addPathPts([0,0,100,0,0], 3000);
        pg.startRTCP(safetyHeight, 16);
        pg.saftyToPt([nan, nan, safetyHeight], pPathSeq(1,1:3), 3000); % safety move the start pt
        pg.enableLaser(1, 5);
        %%% add path pts
        pg.addPathPtsWithPwr(pPathSeq, pwrSeq, lenPosSeq, pFeedrateSeq);
        %%% exist printing mode
        pg.disableLaser(1);
        pg.stopRTCP(200, 16);
        totalPath=[totalPath;pPathSeq];
        startCtrTmp(1)= startCtrTmp(1)+clearanceX;
    end
    startCtr(2)= startCtr(2)+clearanceY;
end
pg.draw_ = true;
pg.drawPath(totalPath, totalPath);
%% end the script
pg.closeScript();

