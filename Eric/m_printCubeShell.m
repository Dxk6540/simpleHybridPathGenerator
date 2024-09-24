addpath('../lib')

% file param:
pFilename = strcat('./cubeShell_Eric',date,'.NC');

hProc = cHybridProcess(pFilename);
% F750£¬ pwr 1200, r 0.75
hProc.sPrintParam_.pFeedrate = 750; % mm/min
hProc.sPrintParam_.powderMode = 1; % both powder are used (for mixing)
hProc.sPrintParam_.pwr = 950/4;
hProc.sProcessParam_.safetyHeight=230;%% Safety height£¡ Attention
shapeHandle = cubeShell();
geoParam = shapeHandle.getDefaultParam();
geoParam.center = [0,0,0];
geoParam.sideLen = 90;
geoParam.lyrNum = 5;
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
hProc.sPrintParam_.speedL = 50;
hProc.sPrintParam_.flowR = 0;
hProc.sPrintParam_.speedR = 0;
% we just want to print one material, the normal printing process is enough.
% (here, one material means the single mixing ratio)
hProc.genNormalPrintingProcess(pg, pPathSeq, pwrSeq, hProc.sPrintParam_.pFeedrate, hProc.sPrintParam_);


pg.closeScript();
pg.drawPath(pPathSeq, pPathSeq);