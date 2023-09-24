% file param:
pFilename = strcat('./bendCylinder',date,'.txt');

hProc = cHybridProcess(pFilename);
hProc.sPrintParam_.pFeedrate = 700; % mm/min
hProc.sPrintParam_.powderMode = 1; % both powder are used (for mixing)
hProc.sPrintParam_.pwr = 250;
hProc.sProcessParam_.usingRTCP = 1;

shapeHandle = bendTube();
geoParam = shapeHandle.getDefaultParam();
geoParam.center = [30,0,0];
geoParam.bendDir = [1,0,0];


%%
%%%%%%%%%%%%%% machining path
%%%% the regular code for generate a script
pg = cPathGen(pFilename); % create the path generator object
pg.genNewScript();
pg.draw_ = true;

[pPathSeq,axisSeq, pwrSeq, feedrateSeq] = shapeHandle.genPrintingPath(geoParam,hProc.sPrintParam_);
bcSeq = sequentialSolveBC(axisSeq, [0,0]);
pPathSeq = [pPathSeq, bcSeq];

% generate process
hProc.sPrintParam_.flowL = 250;
hProc.sPrintParam_.speedL = 100;
hProc.sPrintParam_.flowR = 0;
hProc.sPrintParam_.speedR = 0;
hProc.sPrintParam_.pwr = 0;
% we just want to print one material, the normal printing process is enough.
% (here, one material means the single mixing ratio)
hProc.genNormalPrintingProcess(pg, pPathSeq, pwrSeq, feedrateSeq, hProc.sPrintParam_);


pg.closeScript();
pg.drawPath(pPathSeq, pPathSeq);