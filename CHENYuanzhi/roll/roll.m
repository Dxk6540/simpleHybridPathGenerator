clc; close all;
% file param:
pFilename = strcat('./roll',date,'.txt');
pg = cPathGen(pFilename); % create the path generator object
pg.genNewScript();
pg.draw_ = true;
hProc = cHybridProcess(pFilename);
hProc.sPrintParam_.pFeedrate = 700; % mm/min
hProc.sPrintParam_.powderMode = 1; % both powder are used (for mixing)
hProc.sPrintParam_.pwr = 200;
hProc.sProcessParam_.usingRTCP = 1;

radius=100;
offset=100;
center=[150,100];
dxf = DXFtool('Drawing3.dxf');
[seq,reverse,group]=connectPoints(dxf.points);
[path,on_off,traverse]=connectPath(dxf,seq,reverse,group);
[point_3,angle,height]=convert2DPoint(path,center,radius,offset);
pPathSeq = [point_3, -90*ones(length(angle),1),angle];
pwrSeq=hProc.sPrintParam_.pwr*on_off;
feedrateSeq=hProc.sPrintParam_.pFeedrate+traverse*1000;

% generate process
hProc.sPrintParam_.flowL = 250;
hProc.sPrintParam_.speedL = 100;
hProc.sPrintParam_.flowR = 0;
hProc.sPrintParam_.speedR = 0;
hProc.sPrintParam_.pwr = 0;
% we just want to print one material, the normal printing process is enough.
% (here, one material means the single mixing ratio)
hProc.genNormalPrintingProcess(pg, pPathSeq, pwrSeq, feedrateSeq, hProc.sPrintParam_);
% remember to modify B0 to B-90
pg.closeScript();
pg.drawPath(pPathSeq, pPathSeq);

