% this is an example of generate a single layer machining process
addpath('../lib')
addpath('../lib/shape')

mFilename = strcat('./rtcpCylinderMachining',date,'.txt');

hProc = cHybridProcess(mFilename);
hProc.sMachinParam_.spindleSpeed = 12000; % mm/min
hProc.sMachinParam_.mFeedrate = 3000; % both powder are used
hProc.sMachinParam_.toolNum = 4;
hProc.sMachinParam_.toolRadiu = 4;
hProc.sProcessParam_.usingRTCP = 1;
hProc.sProcessParam_.safetyHeight = 250;

%  geometry param
cylinderGeo = cRtcpCylinder.getDefaultParam();
cylinderGeo.profileRadiu = 44.39;
cylinderGeo.height = 11;
cylinderGeo.center = [-0.1,0.1,159];
cylinderGeo.tol = 0.05;
cylinderGeo.lyrThickness = 0.05; % max rad?
cylinderGeo.rollAgl = pi/6;  %the rot angle is the angle between the tool axis and tangent
side = 1; % machining inside is -1 and outside is 1
wallOffset = 0;
% mPathSeq = cRtcpCylinder.genMachiningPath(radius, startCtr, tol, wpHeight, lyrThichness, toolRadiu, wallOffset, zOffset, side, 0);



%%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%
%%%% the regular code for generate a script
pg = cPathGen(mFilename); % create the path generator object
pg.genNewScript();
pg.draw_ = false;
rtcpCylinderGen = cRtcpCylinder;
mPathSeq = rtcpCylinderGen.genMachiningPath(cylinderGeo, hProc, wallOffset, side, 0);

% hProc.genNormalPrintingProcess(pg, pPathSeq, pwrSeq, hProc.sPrintParam_.pFeedrate, hProc.sPrintParam_);
ret = hProc.genNormalMachiningProcess(pg, mPathSeq, hProc.sMachinParam_.mFeedrate, side, hProc.sMachinParam_);
pg.closeScript();

%%% draw the path
% pg.drawPath(mPathSeq, mPathSeq);








