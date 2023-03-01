% file param:
pFilename = strcat('./cylinderTest',date,'.txt');
mFilename = strcat('./cylinderTestMachinig',date,'.txt');

% process param
% pwr = 300; % 1.2KW / 4kw *1000;
% lenPos = 900;
% flowL = 300; % 6 L/min / 20L/min * 1000;
% speedL = 200;% 2 r/min / 10r/min * 1000;
% flowR = 300;% 6 L/min / 20L/min * 1000;
% speedR = 200;% 2 r/min / 10r/min * 1000;
% feedrate = 760; % mm/min

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
mFeedrate = 1000; % mm/min
spindleSpeed = 10000;
toolNum = 1;
toolRadiu = 4;
wallOffset = 1.9;

%  geometry param
startCtr = [0,40];
% inclinationAgl = 0; % degree
pLyrNum = 300;
% wpH = 10;
lyrHeight = 0.5;
radius = 1;
tol = 0.1;
safetyHeight = 230;
zOffset = 0;

% shape
handle=vase;

%%
%%%%%%%%%%%%%% printing path
[pPathSeq,pwrSeq] = handle.genPrintingPath(radius, startCtr, tol, pLyrNum, lyrHeight, pwr, zOffset, channel, step);
% generate the sequence for pwr / lenPos
lenPosSeq = ones(length(pPathSeq),1) * lenPos;

%%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%
%%%% the regular code for generate a script
pg = cPathGen(pFilename); % create the path generator object
pg.openFile();  % open the file
pg.recordGenTime();
pg.closeDoor(); % close door

%%% start printing mode
pg.changeMode(1); % change to printing mode
pg.setLaser(pwr, lenPos, flowL, speedL, flowR, speedR); % set a init process param (in case of overshoot)
pg.saftyToPt([nan, nan, safetyHeight], [startCtr(1) + radius + 5, startCtr(2), 0], 3000); % safety move the start pt
pg.pauseProgram();% pause and wait for start (the button)
pg.enableLaser(1, 10);

%%% add path pts
pg.addPathPtsWithPwr(pPathSeq, pwrSeq, lenPosSeq, pFeedrate);

%%% exist printing mode
pg.disableLaser(1);

%%% end the script
pg.openDoor();
pg.endProgram();
pg.closeFile();

%%
%%%%%%%%%%%%%% machining path
mPathSeq = handle.genMachiningPath(radius, startCtr, tol, pLyrNum * lyrHeight, lyrHeight, toolRadiu, wallOffset, zOffset);

%%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%
%%%% the regular code for generate a script
pg = cPathGen(mFilename); % create the path generator object
pg.openFile();  % open the file
pg.recordGenTime();
pg.closeDoor(); % close door

%%% start machining mode
pg.changeMode(2); % change to printing mode
pg.changeTool(toolNum);
pg.saftyToPt([nan, nan, safetyHeight], [startCtr(1) - 5, startCtr(2), pLyrNum * lyrHeight], 3000); % safety move the start pt
pg.pauseProgram();% pause and wait for start (the button)
pg.enableSpindle(spindleSpeed, toolNum); % set a init process param (in case of overshoot)

%%% add path pts
pg.addPathPts(mPathSeq, mFeedrate);

%%% exist machining mode
pg.disableSpindle();
% pg.addCmd("G01 Z200 F3000 ;;抬刀至安全平面");
% pg.saftyToPt([nan, nan, safetyHeight], [startCtr(1) - 5, startCtr(2), safetyHeight], 3000); % safety move the start pt
pg.returnToSafety(220, 3000);

%%% end the script
pg.openDoor();
pg.endProgram();
pg.closeFile();

%%% draw the path
pg.drawPath(pPathSeq, mPathSeq);
