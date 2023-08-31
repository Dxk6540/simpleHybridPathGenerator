addpath('./lib')

% file param:
pFilename = strcat('./tutorial8_cubeShell',date,'.txt');

hProc = cHybridProcess(pFilename);
hProc.sPrintParam_.pFeedrate = 600; % mm/min
hProc.sPrintParam_.powderMode = 1; % both powder are used (for mixing)
hProc.sPrintParam_.pwr = 150;

shapeHandle = cubeShell();
geoParam = shapeHandle.getDefaultParam();
geoParam.center = [55,55,0];
geoParam.sideLen = 30;


%%
%%%%%%%%%%%%%% machining path
%%%% the regular code for generate a script
pg = cPathGen(pFilename); % create the path generator object
pg.genNewScript();
pg.draw_ = true;

[pPathSeq, pwrSeq] = shapeHandle.genPrintingPath(geoParam, hProc.sPrintParam_);

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