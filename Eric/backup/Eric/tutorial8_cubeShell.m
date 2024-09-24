addpath('../lib')

% file param:
pFilename = strcat('./tutorial8_cubeShell',date,'.txt');

hProc = cHybridProcess(pFilename);
% F750£¬ pwr 1200, r 0.75
hProc.sPrintParam_.pFeedrate = 750; % mm/min
hProc.sPrintParam_.powderMode = 1; % both powder are used (for mixing)
hProc.sPrintParam_.pwr = 200;

shapeHandle = cubeShell();¡¤
geoParam = shapeHandle.getDefaultParam();
geoParam.center = [10,-20,0];
geoParam.sideLen = 20;
geoParam.lyrNum = 10;
geoParam.lyrThickness = 0.5;

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