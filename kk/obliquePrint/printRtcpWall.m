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
hProc.sPrintParam_.pwr = 250; % mm/min
hProc.sPrintParam_.flowL = 250; % 6 L/min / 20L/min * 1000;
hProc.sPrintParam_.speedL = 100; % 2 r/min / 10r/min * 1000;
hProc.sPrintParam_.pFeedrate = 600;
hProc.sPrintParam_.powderMode = 1; % left
hProc.sProcessParam_.usingRTCP = 1;
%  geometry param
wallGeo = inclineWallKK.getDefaultParam();
wallGeo.startPt = [0,0];
wallGeo.endPt = [10,10];
wallGeo.height = 5;
wallGeo.Zoffset = 70;
wallGeo.tol = 0.1;
wallGeo.lyrThickness = 0.5; % max rad?
wallGeo.rollAgl = 15;  %the rot angle is the angle between the tool axis and tangent


safetyHeight = 230;
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


