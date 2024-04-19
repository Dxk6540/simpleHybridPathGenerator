% printing a gradient material with fixed powder mixing ratio,

% file param:
pFilename = strcat('./zichuanExample_Test',date,'.txt');

hProc = cHybridProcess(pFilename);
hProc.sPrintParam_.pFeedrate = 600; % mm/min
hProc.sPrintParam_.powderMode = 3; % both powder are used (for mixing)
hProc.sPrintParam_.pwr = 150;

%  geometry param
startPt = [-10,-10]; % (minX, minY)
cubeLen = 20; % length along X dir
cubeChannel = 21; % channels when printing
pLyrNum = 20;
lyrHeight = 0.3;
tol = 0.1;
zOffset = 0;
step = 1;

% shape
handle = zigzagPathCube;
cubeShape = [cubeLen, cubeChannel];


%%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%
%%%% the regular code for generate a script
pg = cPathGen(pFilename); % create the path generator object
pg.genNewScript();
pg.draw_ = true;

% gnerate printing path 
[pPathSeq, pwrSeq] = handle.genPrintingPath(cubeShape, startPt, tol, pLyrNum, ...
                                                lyrHeight, hProc.sPrintParam_.pwr, zOffset, 0, step);

% generate process
hProc.sPrintParam_.flowL = 250;
hProc.sPrintParam_.speedL = 0;
hProc.sPrintParam_.flowR = 500;
hProc.sPrintParam_.speedR = 100;
% we just want to print one material, the normal printing process is enough.
% (here, one material means the single mixing ratio)
hProc.genNormalPrintingProcess(pg, pPathSeq, pwrSeq, hProc.sPrintParam_.pFeedrate, hProc.sPrintParam_);

pg.closeScript();
pg.drawPath(pPathSeq, pPathSeq);


