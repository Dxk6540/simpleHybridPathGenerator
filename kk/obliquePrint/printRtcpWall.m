%%%%%%%%%%%%%%%
% oblique wall printing. 
% 20240409.
% Xiaoke DENG 
%%%%%%%%%%%%%%%


% this is an example of generate a single layer machining process
addpath('../../lib')
addpath('../../lib/shape')

mFilename = strcat('./rtcpWallPrint',date,'.txt');

hProc = cHybridProcess(mFilename);
hProc.sPrintParam_.pwr = 100; % mm/min
hProc.sPrintParam_.flowL = 200; % 6 L/min / 20L/min * 1000;
hProc.sPrintParam_.speedL = 60; % 2 r/min / 10r/min * 1000;
hProc.sPrintParam_.pFeedrate = 800;
hProc.sPrintParam_.powderMode = 1; % left
hProc.sProcessParam_.usingRTCP = 1;
hProc.sProcessParam_.safetyHeight = 30;
%  geometry param
wallGeo = inclineWallKK.getDefaultParam();
wallGeo.startPt = [-17.1,1.8];
wallGeo.endPt = [26.2,0.8];
wallGeo.height = 20;
wallGeo.Zoffset = -40;
wallGeo.tol = 0.1;
wallGeo.lyrThickness = 1; % max rad?
wallGeo.rollAgl = 60;  %the rot angle is the angle between the tool axis and tangent
wallGeo.inverseC = 1;

side = 1; % machining inside is -1 and outside is 1
wallOffset = 0;


%%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%
%%%% the regular code for generate a script
pg = cPathGen(mFilename); % create the path generator object
pg.genNewScript();
pg.draw_ = true;

[pPathSeq,pwrSeq] = inclineWallKK.genPrintingPath(wallGeo, hProc);

hProc.genNormalPrintingProcess(pg, pPathSeq, pwrSeq, hProc.sPrintParam_.pFeedrate, hProc.sPrintParam_);
% ret = hProc.genNormalMachiningProcess(pg, mPathSeq, hProc.sMachinParam_.mFeedrate, side, hProc.sMachinParam_);
pg.closeScript();

%%% draw the path
pg.drawPath(pPathSeq, pPathSeq);


