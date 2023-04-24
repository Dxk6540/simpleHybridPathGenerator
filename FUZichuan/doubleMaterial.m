%%%%%%%%%%%%%%%%%%%
%
% date: 2023-4-24
% author： CHEN Yuanzhi
%
%%%%%%%%%%%%%%%%%%

% file param:
hFilename = strcat('./doubleMaterial',date,'.txt');

% printing process param
pwr = 300; % 1.2KW / 4kw *1000;
lenPos = 900;
flowL = 250; % 6 L/min / 20L/min * 1000;
speedL = 100;% 2 r/min / 10r/min * 1000;
flowR = 250;% 6 L/min / 20L/min * 1000;
speedR = 100;% 2 r/min / 10r/min * 1000;
pFeedrate = 600; % mm/min
step = 1;

% machining process param
mFeedrate = 1400; % mm/min
spindleSpeed = 10000;
toolNum = 1;
toolRadiu = 4;

%  geometry param
startCtr = [30,30];
pLyrNum = 2;
lyrHeight = 0.5;
cubeShape = [20,20];
tol = 0.01;
safetyHeight = 230;
zOffset = 0;
angle = 10;
rotation = true;
side = 1; % machining inside is -1 and outside is 1
wallOffset = 1.1;

% shape
handle = rotationalZigzagPathCube;

%%
%%%%%%%%%%%%%% printing path
[pPathSeq,pwrSeq,feedOffset] = handle.genPrintingPath(cubeShape, startCtr, pLyrNum, lyrHeight, pwr, zOffset, angle, rotation, step);
lenPosSeq = ones(length(pPathSeq),1) * lenPos;
%%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%
%%%% the regular code for generate a script
pg = cPathGen(hFilename); % create the path generator object
pg.genNewScript();
%%% start printing mode
pg.changeMode(1); % change to printing mode
pg.setLaser(pwr, lenPos, flowL, speedL, flowR, speedR); % set a init process param (in case of overshoot)
pg.saftyToPt([nan, nan, safetyHeight], [startCtr(1) + radius, startCtr(2), 0], 3000); % safety move the start pt
pg.pauseProgram();% pause and wait for start (the button)
pg.enableLaser(1, 10);
%%% add path pts
pg.addPathPtsWithPwr(pPathSeq, pwrSeq, lenPosSeq, pFeedrate*feedOffset);
%%% exist printing mode
pg.disableLaser(1);
% %%% end the script
pg.closeScript();
pg.draw_ = true;
pg.drawPath(pPathSeq, pPathSeq);


%%
%%%%%%%%%%%%%% machining path
[toolContactPts, toolCntrPts, toolAxisSeq, fcNormalSeq] = handle.genMachiningPath(radius, startCtr, tol, wpHeight, lyrHeight, toolRadiu, wallOffset, zOffset, rollAgl, side);
bcSeq = sequentialSolveBC(toolAxisSeq, [0,0]);
mPathSeq = [toolCntrPts, bcSeq];

%%%%%%%%%%%%% following for RTCP path Gen %%%%%%%%%%%%%%%%%%%%%
%%%% the regular code for generate a script
pg = cPathGen(hFilename); % create the path generator object
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
pg.stopRTCP(safetyHeight);
pg.returnToSafety(safetyHeight, 3000);
%%% end the script
pg.closeScript();



%%% draw the path
pg.drawPath(pPathSeq, mPathSeq);


