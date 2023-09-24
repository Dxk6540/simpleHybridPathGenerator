addpath('./lib')

% file param:
pFilename = strcat('./tutorial8_triShellV2',date,'.txt');

hProc = cHybridProcess(pFilename);
% F750£¬ pwr 1200, r 0.75
hProc.sPrintParam_.pFeedrate = 750 ; % mm/min
hProc.sPrintParam_.powderMode = 1; % both powder are used (for mixing)
hProc.sPrintParam_.pwr = 300;

shapeHandle = triShell();
geoParam = shapeHandle.getDefaultParam();
geoParam.center = [0, 0, 0];
geoParam.sideLen = 30;
geoParam.lyrNum = 90;
geoParam.lyrThickness = 0.33;

%%
%%%%%%%%%%%%%% machining path
%%%% the regular code for generate a script
pg = cPathGen(pFilename); % create the path generator object
pg.genNewScript();
pg.draw_ = true;

[pPathSeq, pwrSeq] = shapeHandle.genPrintingPath(geoParam, hProc.sPrintParam_);

% generate process
hProc.sPrintParam_.flowL = 250;
hProc.sPrintParam_.speedL = 100;
hProc.sPrintParam_.flowR = 500;
hProc.sPrintParam_.speedR = 100;
% we just want to print one material, the normal printing process is enough.
% (here, one material means the single mixing ratio)
hProc.genNormalPrintingProcess(pg, pPathSeq, pwrSeq, hProc.sPrintParam_.pFeedrate, hProc.sPrintParam_);


pg.closeScript();
pg.drawPath(pPathSeq, pPathSeq);