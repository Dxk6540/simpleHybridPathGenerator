% file param:
hFilename = strcat('./Wall',date,'.txt');

% printing process param
pwr = 250; % 1.2KW / 4kw *1000;
lenPos = 900;
flowL = 250; % 6 L/min / 20L/min * 1000;
speedL = 100;% 2 r/min / 10r/min * 1000;
flowR = 250;% 6 L/min / 20L/min * 1000;
speedR = 100;% 2 r/min / 10r/min * 1000;
pFeedrate = 600; % mm/min
step = 1;
channel = 3;
powderMode = 1;
lead = 5;

% machining process param
mFeedrate = 300; % mm/min
traversalSpeed=1500;
spindleSpeed = 10000;
toolNum = 3;
toolRadiu = 5;
depth = 0.1;

%  geometry param
startCtr = [30,50];
pLyrNum = 10;
lyrHeight = 0.5;
safetyHeight = 230;
zOffset = 0;
wallOffset = 1.5;
wallLength = 20;
wallWidth=(channel+1)*step;

% shape
handle = zigzagWall;
pg = cPathGen(hFilename); % create the path generator object
pg.genNewScript();

%%%%%%% gen printing process %%%%%%
pg.addCmd(";;;;;start a printing process;;;;;;;;;;");
pg.changeMode(1);
[pPathSeq, pwrSeq, feedOffset] = handle.genPrintingPath(wallLength, startCtr, lead, pLyrNum, lyrHeight, pwr, zOffset, channel, step);
lenPosSeq = ones(length(pPathSeq),1) * lenPos;
pg.setLaser(0, lenPos, flowL, speedL, flowR, speedR); % set a init process param (in case of overshoot)
pg.saftyToPt([nan, nan, safetyHeight], pPathSeq(1,:), 3000); % safety move the start pt
pg.pauseProgram();% pause and wait for start (the button)
pg.enableLaser(powderMode, 10);
%%% add path pts
pg.addPathPtsWithPwr(pPathSeq, pwrSeq, lenPosSeq, pFeedrate);
%%% exist printing mode
pg.disableLaser(powderMode);

%%%%%%%%%%%%%%%%%%%%%%%% gen outter machining process %%%%%%%%%%%%%%%%%%%%%%%
pg.addCmd(";;;;;start an outter machining process");    
[mPathSeq, mFeedrateSeq] = handle.genMachiningPath(wallLength, wallWidth, startCtr, mFeedrate, traversalSpeed, toolRadiu, wallOffset, depth, zOffset);
pg.changeMode(2); % change to machining mode
pg.changeTool(toolNum);
pg.saftyToPt([nan, nan, safetyHeight], [startCtr(1)-toolRadiu-wallOffset-5, startCtr(2)-toolRadiu, zOffset], 3000); % safety move the start pt
pg.pauseProgram();% pause and wait for start (the button)
pg.enableSpindle(spindleSpeed, toolNum); % set a init process param (in case of overshoot)
%% add path pts
pg.addPathPts(mPathSeq, mFeedrateSeq);
%% exist machining mode
pg.disableSpindle();
pg.returnToSafety(safetyHeight, 3000);

pg.draw_ = true;
pg.drawPath(pPathSeq, mPathSeq);
%%% end the script
pg.closeScript();