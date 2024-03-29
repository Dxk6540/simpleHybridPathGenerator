% this is an example of generate a single layer machining process
addpath('../lib')
addpath('../lib/shape')

mFilename = strcat('./rtcpCylinderMachining',date,'.txt');

hProc = cHybridProcess(mFilename);
hProc.sMachinParam_.spindleSpeed = 8000; % mm/min
hProc.sMachinParam_.mFeedrate = 1000; % both powder are used
hProc.sMachinParam_.toolNum = 3;
hProc.sMachinParam_.toolRadiu = 3;
hProc.sProcessParam_.usingRTCP = 1;
%  geometry param
cylinderGeo = cRtcpCylinder.getDefaultParam();
cylinderGeo.profileRadiu = 20;
cylinderGeo.height = 12;
cylinderGeo.center = [-35,60,4];
cylinderGeo.tol = 0.1;
cylinderGeo.lyrThickness = 0.5; % max rad?
cylinderGeo.rollAgl = pi/12;  %the rot angle is the angle between the tool axis and tangent
safetyHeight = 230;
side = 1; % machining inside is -1 and outside is 1
wallOffset = 0;
% mPathSeq = cRtcpCylinder.genMachiningPath(radius, startCtr, tol, wpHeight, lyrThichness, toolRadiu, wallOffset, zOffset, side, 0);



%%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%
%%%% the regular code for generate a script
pg = cPathGen(mFilename); % create the path generator object
pg.genNewScript();
pg.draw_ = true;
rtcpCylinderGen = cRtcpCylinder;
mPathSeq = rtcpCylinderGen.genMachiningPath(cylinderGeo, hProc, wallOffset, side, 0);

% hProc.genNormalPrintingProcess(pg, pPathSeq, pwrSeq, hProc.sPrintParam_.pFeedrate, hProc.sPrintParam_);
ret = hProc.genNormalMachiningProcess(pg, mPathSeq, hProc.sMachinParam_.mFeedrate, side, hProc.sMachinParam_);
pg.closeScript();

%%% draw the path
% pg.drawPath(mPathSeq, mPathSeq);








