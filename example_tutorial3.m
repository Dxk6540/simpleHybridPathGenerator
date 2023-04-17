% this is an example of generate a single layer machining process

% file param:
pFilename = strcat('./tutorial3_machiningTest',date,'.txt');

hProc = cHybridProcess(pFilename);
hProc.sMachinParam_.spindleSpeed = 8000; % mm/min
hProc.sMachinParam_.mFeedrate = 1000; % both powder are used
hProc.sMachinParam_.toolNum = 2;
hProc.sMachinParam_.toolRadiu = 3;

%  geometry param
startCtr = [60,-45];
pLyrNum = 30;
lyrHeight = 0.3;
radius = 40;
tol = 0.1;
zOffset = 0.5;
channel = 6;
step = 1;

% shape
handle=contourPathCube;



%%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%
%%%% the regular code for generate a script
pg = cPathGen(pFilename); % create the path generator object
pg.genNewScript();
pg.draw_ = true;

% path = genMachiningPath(cubeLength, startPoint, tol, wpHeight, lyrThickness, toolRadiu, wallOffset, zOffset,side)
wallOffset = 0.6;
side = 1;
mPathSeq = handle.genMachiningPath(radius, 5, startCtr, tol, pLyrNum * lyrHeight, ...
                                                lyrHeight, hProc.sMachinParam_.toolRadiu, wallOffset, zOffset, side);

% hProc.genNormalPrintingProcess(pg, pPathSeq, pwrSeq, hProc.sPrintParam_.pFeedrate, hProc.sPrintParam_);
ret = hProc.genNormalMachiningProcess(pg, mPathSeq, hProc.sMachinParam_.mFeedrate, side, hProc.sMachinParam_);
pg.closeScript();

%%% draw the path
pg.drawPath(mPathSeq, mPathSeq);


