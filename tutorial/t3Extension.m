% this is an example of generate a single layer machining process
addpath('../lib/shape')
% file param:
pFilename = strcat('./hatMachining',date,'.txt');

hProc = cHybridProcess(pFilename);
hProc.sMachinParam_.spindleSpeed = 8000; % mm/min
hProc.sMachinParam_.mFeedrate = 3000; % both powder are used
hProc.sMachinParam_.toolNum = 4;
hProc.sMachinParam_.toolRadiu = 3;

%  geometry param
startCtr = [78,0];
zRange = [88.5, 86];
rRange = [15, 25];
pLyrNum = 30;
lyrHeight = 0.15;
radius = 40;
tol = 0.1;
zOffset = 0.5;
channel = 6;
step = 1;

% shape
% handle=planarCircleMachining;



%%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%
%%%% the regular code for generate a script
pg = cPathGen(pFilename); % create the path generator object
pg.genNewScript();
pg.draw_ = true;

% path = genMachiningPath(cubeLength, startPoint, tol, wpHeight, lyrThickness, toolRadiu, wallOffset, zOffset,side)
wallOffset = 0.6;
side = 1;
mPathSeq = planarCircleMachining(startCtr, zRange, rRange, -lyrHeight, ...
                                                hProc.sMachinParam_.toolRadiu, hProc.sMachinParam_.mFeedrate, 500);

% hProc.genNormalPrintingProcess(pg, pPathSeq, pwrSeq, hProc.sPrintParam_.pFeedrate, hProc.sPrintParam_);
ret = hProc.genNormalMachiningProcess(pg, mPathSeq, hProc.sMachinParam_.mFeedrate, side, hProc.sMachinParam_);
pg.closeScript();

%%% draw the path
pg.drawPath(mPathSeq, mPathSeq);


