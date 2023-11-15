%%%%%%%%%%%%%%%%%%%
%
% with RTCP function.
% date: 2023-3-3
%
%%%%%%%%%%%%%%%%%%

% file param:
pFilename = strcat('./vaseTest',date,'.txt');
mFilename = strcat('./vaseTestMachinig',date,'.txt');

% printing process param
pwr = 300; % 1.2KW / 4kw *1000;
lenPos = 900;
flowL = 250; % 6 L/min / 20L/min * 1000;
speedL = 100;% 2 r/min / 10r/min * 1000;
flowR = 250;% 6 L/min / 20L/min * 1000;
speedR = 100;% 2 r/min / 10r/min * 1000;
pFeedrate = 600; % mm/min
channel = 2;
step = 1;

% machining process param
mFeedrate = 4000; % mm/min
spindleSpeed = 10000;
toolNum = 1;
toolRadiu = 4;
toolLen = 30;

%  geometry param
startCtr = [0,0];
pLyrNum = 100;
lyrHeight = 0.5;
radius = 30;
tol = 0.1;
safetyHeight = 230;
zOffset = 85;
side = 1; % machining inside is -1 and outside is 1
wallOffset = 0;
rollAgl = pi/6; %the rot angle is the angle between the tool axis and tangent
% rollAgl = 0;
wpHeight = pLyrNum*lyrHeight;


% shape
handle=vase;

% %%
% %%%%%%%%%%%%%% printing path
% [pPathSeq,pwrSeq] = vase.genPrintingPath(radius, startCtr, tol, pLyrNum, lyrHeight, pwr, zOffset, channel, step);
% lenPosSeq = ones(length(pPathSeq),1) * lenPos;
% %%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%
% %%%% the regular code for generate a script
% pg = cPathGen(pFilename); % create the path generator object
% pg.genNewScript();
% %%% start printing mode
% pg.changeMode(1); % change to printing mode
% pg.setLaser(pwr, lenPos, flowL, speedL, flowR, speedR); % set a init process param (in case of overshoot)
% pg.saftyToPt([nan, nan, safetyHeight], [startCtr(1) + radius, startCtr(2), 0], 3000); % safety move the start pt
% pg.pauseProgram();% pause and wait for start (the button)
% pg.enableLaser(1, 10);
% %%% add path pts
% pg.addPathPtsWithPwr(pPathSeq, pwrSeq, lenPosSeq, pFeedrate);
% %%% exist printing mode
% pg.disableLaser(1);
% % %%% end the script
% pg.closeScript();



%%
%%%%%%%%%%%%%% machining path
mPathSeq = vase.genMachiningPath(radius, startCtr, tol, 38, 0.2, toolRadiu, wallOffset, zOffset, side, 0);

%%%%%%%%%%%%% following for RTCP path Gen %%%%%%%%%%%%%%%%%%%%%
%%%% the regular code for generate a script
pg = cPathGen(mFilename); % create the path generator object
pg.genNewScript();
%%% start machining mode
pg.changeMode(2); % change to machining mode
pg.changeTool(toolNum);
pg.startRTCP(safetyHeight, toolNum);
pg.saftyToPt([nan, nan, safetyHeight], [startCtr(1) + side*(radius + toolRadiu + wallOffset + 5), startCtr(2), pLyrNum * lyrHeight], 3000); % safety move the start pt
pg.pauseProgram();% pause and wait for start (the button)
pg.enableSpindle(spindleSpeed, toolNum); % set a init process param (in case of overshoot)
%%% add path pts
pg.addPathPts(mPathSeq, mFeedrate);
%%% exist machining mode
pg.disableSpindle();
pg.stopRTCP(safetyHeight, toolNum);
pg.returnToSafety(safetyHeight, 3000);
%%% end the script
pg.closeScript();



%%% draw the path
pg.drawPath(mPathSeq, mPathSeq);


