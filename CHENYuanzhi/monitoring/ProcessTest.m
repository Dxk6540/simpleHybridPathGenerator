%%%%%%%%%%%%%%%%%%%
%
% date: 2023-5-15
% author: CHEN Yuanzhi
%
%%%%%%%%%%%%%%%%%%
% printing process param
pwr = 250; % 1.2KW / 4kw *1000;
pFeedrate = 400; % mm/min
lenPos = 400;

% file param:
hFilename = strcat('./ProcessTest_',num2str(pwr),'_',num2str(pFeedrate),'_',num2str(lenPos),'.txt');

flowL = 250; % 6 L/min / 20L/min * 1000;
speedL = 100;% 2 r/min / 10r/min * 1000;
flowR = 400;% 6 L/min / 20L/min * 1000;
speedR = 100;% 2 r/min / 10r/min * 1000;
safetyHeight = 25;
lyrNum=4;
lyrHeight=0.6;

powderMode = 2;
%  geometry param
traverse=2000;
% shape
handle = processTestSinglechannelsinglelayer;

%%
%%%%%%%%%%%%%% printing path
%%%% the regular code for generate a script
pg = cPathGen(hFilename); % create the path generator object
pg.genNewScript();
%%% Beam1
pg.changeMode(1); % change to printing mode
[pPathSeq,pwrSeq, pFeedrateSeq,vertices] = handle.genPrintingPath(pwr, pFeedrate, traverse, lyrNum, lyrHeight);
lenPosSeq = ones(length(pPathSeq),1) * lenPos;

% preheat codes
[pPathSeqHeat,pwrSeqHeat, pFeedrateSeqHeat,vertices] = handle.genPrintingPath(pwr, pFeedrate, traverse, 1, 0);
lenPosSeqHeat = ones(length(pPathSeqHeat),1) * lenPos;


%%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%
%%% start printing mode
pg.setLaser(0, lenPos, flowL, 0, flowR, 0); % set a init process param (in case of overshoot)
pg.addPathPts([0,0,safetyHeight,0,0], 3000);
pg.addPathPts([0,0,safetyHeight,0,0], 3000);
pg.saftyToPt([nan, nan, safetyHeight], pPathSeqHeat(1,:), 500); % safety move the start pt
pg.enableLaser(powderMode, 10);

% preheat
pg.addPathPtsWithPwr(pPathSeqHeat, pwrSeqHeat, lenPosSeqHeat, pFeedrateSeqHeat); 

%%% printing
pg.changePowder(flowL, speedL, flowR, speedR, 30); % delay 10s for change powder
pg.addPathPtsWithPwr(pPathSeq, pwrSeq, lenPosSeq, pFeedrateSeq);

pg.disableLaser(powderMode);

%%% draw
pg.draw_ = false;
pg.drawPath(pPathSeq, pPathSeq);
%% end the script
pg.closeScript();