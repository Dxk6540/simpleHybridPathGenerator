% this is an example of generate multi-layer machining process
addpath('../lib')
addpath('../lib/shape')

% file param:
pFilename = strcat('./tutorial3_machiningContour',date,'.txt');

hProc = cHybridProcess(pFilename);
hProc.sMachinParam_.spindleSpeed = 8000; % mm/min
hProc.sMachinParam_.mFeedrate = 1000; % both powder are used
hProc.sMachinParam_.toolNum = 2;
hProc.sMachinParam_.toolRadiu = 3;

%  geometry param
startCtr = [0,0];
cubeShape = [40,20];
pLyrNum = 20;
lyrHeight = 0.3;
wpHeight = pLyrNum * lyrHeight;
radius = 40;
tol = 0.1;
zOffset = 3;
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
allPath = [];
for i = 5:-1:0
    mPathSeq = handle.genMachiningPath(cubeShape(1), cubeShape(2), startCtr, tol, wpHeight, ...
                                                    lyrHeight, hProc.sMachinParam_.toolRadiu, wallOffset*i, zOffset, side);
    allPath = [allPath;mPathSeq];
end
% hProc.genNormalPrintingProcess(pg, pPathSeq, pwrSeq, hProc.sPrintParam_.pFeedrate, hProc.sPrintParam_);
ret = hProc.genNormalMachiningProcess(pg, mPathSeq, hProc.sMachinParam_.mFeedrate, side, hProc.sMachinParam_);
pg.closeScript();

%%% draw the path
pg.drawPath(allPath, allPath);


