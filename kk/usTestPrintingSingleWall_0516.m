% printing a gradient material with fixed powder mixing ratio,

% file param:
pFilename = strcat('./usTestPrintingSingleWall',date,'.txt');

hProc = cHybridProcess(pFilename);
hProc.sPrintParam_.pFeedrate = 400; % mm/min
hProc.sPrintParam_.powderMode = 1; % both powder are used (for mixing)
hProc.sPrintParam_.pwr = 200;
% hProc.sPrintParam_.speedL = 0;
% hProc.sPrintParam_.flowL = 50;

%  geometry param
startPt = [0,0]; % (minX, minY
cubeLen = 60; % length along X dir
cubeChannel = 1; % channels when printing
pLyrNum = 21;
lyrHeight = 0.5;
tol = 0.1;
zOffset = 0;
step = 0;

% shape
handle = zigzagPathCube;
cubeShape = [cubeLen, cubeChannel];


%%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%
%%%% the regular code for generate a script
pg = cPathGen(pFilename); % create the path generator object
pg.genNewScript();
pg.draw_ = true;
centerOff = [30,5];
% gnerate printing path 
startPt = [0,0]-centerOff; % (minX, minY
[pPathSeq, pwrSeq] = handle.genPrintingPath(cubeShape, startPt, tol, pLyrNum, ...
                                                lyrHeight, hProc.sPrintParam_.pwr, zOffset, 0, step);
                                            
                                            
                                            
% generate process
hProc.sPrintParam_.flowL = 250;
hProc.sPrintParam_.speedL = 100;
hProc.sPrintParam_.flowR = 0;
hProc.sPrintParam_.speedR = 0;
% we just want to print one material, the normal printing process is enough.
% (here, one material means the single mixing ratio)
hProc.genNormalPrintingProcess(pg, pPathSeq, pwrSeq, hProc.sPrintParam_.pFeedrate, hProc.sPrintParam_);

pg.closeScript();
pg.drawPath(pPathSeq, pPathSeq);


