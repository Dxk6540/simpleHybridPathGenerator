filename = strcat('./remelt_',date,'.txt');
hProc = cHybridProcess(filename);
hProc.sPrintParam_.powderMode = 1; % both powder are used
%  geometry param
% startCtr = [0,0]; % left bottom corner

% inclinationAgl = 0; % degree
pLyrNum = 1;
tol = 0.1;
zOffset = -42;
channel = 14;
step = 0.8;
cubeShape = [20,25];
lbPt = [181.814,14.3];
lyrHeight = 0.5;
handle=zigzagPathCube;

pg = cPathGen(filename); % create the path generator object
pg.genNewScript();
hProc.sPrintParam_.pFeedrate = 900;
hProc.sPrintParam_.pwr = 180;
[pPathSeq,pwrSeq, feedSeq] = handle.genPrintingPathV2(cubeShape, lbPt, tol, pLyrNum, ...
                                                lyrHeight, hProc.sPrintParam_.pwr, zOffset, channel, step);
hProc.genNormalPrintingProcess(pg, pPathSeq, pwrSeq, hProc.sPrintParam_.pFeedrate, hProc.sPrintParam_);    
pg.closeScript();
%% draw the path
pg.drawPath(pPathSeq, pPathSeq);