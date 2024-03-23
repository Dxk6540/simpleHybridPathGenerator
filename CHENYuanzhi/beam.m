%%%%%%%%%%%%%%%%%%%
%
% date: 2023-5-15
% author: CHEN Yuanzhi
%
%%%%%%%%%%%%%%%%%%

% file param:
hFilename = strcat('./inclinePrintedWall',date,'.txt');

% printing process param
pwr = 200; % 1.2KW / 4kw *1000;
lenPos = 900;
flowL = 250; % 6 L/min / 20L/min * 1000;
speedL = 100;% 2 r/min / 10r/min * 1000;
flowR = 400;% 6 L/min / 20L/min * 1000;
speedR = 100;% 2 r/min / 10r/min * 1000;
pFeedrate = 500; % mm/min
step = 0.8;
safetyHeight = 200;

%  geometry param
startCtr = [-30,20,30];
pLyrNum = 40;
lyrHeight = 0.5;
wallLength = 10;
clearance=0.5;
lead = 2.5;
inclineAngle = 30;
channel = 2;

% shape
handle = inclinePrintedBeam;

%%
%%%%%%%%%%%%%% printing path
%%%% the regular code for generate a script
pg = cPathGen(hFilename); % create the path generator object
pg.genNewScript();
totalPath=[];
for inclineAngle = 40:40
    pg.changeMode(1); % change to printing mode
    [pPathSeq,pwrSeq] = handle.genPrintingPath(wallLength, startCtr, lead, pLyrNum, lyrHeight, pwr, inclineAngle, channel, step);
    lenPosSeq = ones(length(pPathSeq),1) * lenPos;
    %%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%
    %%% start printing mode
    pg.setLaser(0, lenPos, flowL, speedL, flowR, speedR); % set a init process param (in case of overshoot)
    pg.addPathPts([0,0,safetyHeight,inclineAngle,0], pFeedrate);
    pg.startRTCP(safetyHeight, 16);
    pg.saftyToPt([nan, nan, safetyHeight], pPathSeq(1,:), 3000); % safety move the start pt
    pg.enableLaser(1, 10);
    %%% add path pts
    pg.addPathPtsWithPwr(pPathSeq, pwrSeq, lenPosSeq, pFeedrate);
    %%% exist printing mode
    pg.disableLaser(1);
    pg.stopRTCP(safetyHeight, 16);
    totalPath=[totalPath;pPathSeq];
    startCtr(3)= startCtr(3)+clearance;
end
pg.draw_ = true;
pg.drawPath(totalPath, totalPath);
%% end the script
pg.closeScript();

