%%%%%%%%%%%%%%%%%%%
%
% with RTCP function.
% date: 2023-3-3
%
%%%%%%%%%%%%%%%%%%

% file param:
hFilename = strcat('./MediaMold',date,'.txt');

% printing process param
pwr = 200; % 1.2KW / 4kw *1000;
lenPos = 900;
flowL = 250; % 6 L/min / 20L/min * 1000;
speedL = 100;% 2 r/min / 10r/min * 1000;
flowR = 250;% 6 L/min / 20L/min * 1000;
speedR = 100;% 2 r/min / 10r/min * 1000;
pFeedrate = 400; % mm/min
channel = 1;
step = 1;

% machining process param
mFeedrate = 400; % mm/min
spindleSpeed = 10000;
toolNum = 1;
toolRadiu = 1;

%  geometry param
startCtr = [0,0];
pLyrNum = 10;
lyrHeight = 0.5;
radius = 1.5;
tol = 0.01;
safetyHeight = 230;
zOffset = 0;
side = -1; % machining inside is -1 and outside is 1
wallOffset = 0.475;
rollAgl = 0;

% shape
handle=hollowCylinder;

%%%% the regular code for generate a script
pg = cPathGen(hFilename); % create the path generator object
pg.genNewScript();

%%
%%%%%%%%%%%%%% printing path
[pPathSeq,pwrSeq] = handle.genPrintingPath(radius, startCtr, tol, pLyrNum, lyrHeight, pwr, zOffset, channel, step);
lenPosSeq = ones(length(pPathSeq),1) * lenPos;
%%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%
%%% start printing mode
pg.changeMode(1); % change to printing mode
pg.setLaser(pwr, lenPos, flowL, speedL, flowR, speedR); % set a init process param (in case of overshoot)
pg.saftyToPt([nan, nan, safetyHeight], [startCtr(1) + radius, startCtr(2), 0], 3000); % safety move the start pt
pg.pauseProgram();% pause and wait for start (the button)
pg.enableLaser(1, 10);
%%% add path pts
pg.addPathPtsWithPwr(pPathSeq, pwrSeq, lenPosSeq, pFeedrate);
%%% exist printing mode
pg.disableLaser(1);
% %%% end the script


%%
%%%%%%%%%%%%%% machining path
mPathSeq = handle.genMachiningPath(radius, startCtr, tol, pLyrNum * lyrHeight, lyrHeight, toolRadiu, wallOffset, zOffset, rollAgl, side, 5);

%%% start machining mode
pg.changeMode(2); % change to machining mode
pg.changeTool(toolNum);
pg.saftyToPt([nan, nan, safetyHeight], [startCtr(1) + side*(radius + toolRadiu + wallOffset + 5), startCtr(2), pLyrNum * lyrHeight], 3000); % safety move the start pt
pg.pauseProgram();% pause and wait for start (the button)
pg.enableSpindle(spindleSpeed, toolNum); % set a init process param (in case of overshoot)
%%% add path pts
pg.addPathPts(mPathSeq, mFeedrate);
%%% exist machining mode
pg.disableSpindle();
pg.returnToSafety(safetyHeight, 3000);
%%% end the script
pg.closeScript();

%%% draw the path
pg.draw_ = true;
pg.drawPath(pPathSeq, mPathSeq);


