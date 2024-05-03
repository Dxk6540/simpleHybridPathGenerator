clc; close all;
% file param:
dxfFile='Drawing4.dxf';
dxf = DXFtool(dxfFile);
pFilename = strcat('./roll_',dxfFile,'_',date,'.txt');
pg = cPathGen(pFilename); % create the path generator object
pg.genNewScript();
pg.draw_ = true;
hProc = cHybridProcess(pFilename);
hProc.sPrintParam_.pFeedrate = 400; % mm/min
hProc.sPrintParam_.powderMode = 1; % both powder are used (for mixing)
hProc.sPrintParam_.pwr = 200;
hProc.sProcessParam_.usingRTCP = 0;

radius=38.1;
offset=240;
center=[150,100];
cylinderAxis=[0,0,1];
cylinderOrin=[0,0,0];
[seq,reverse,group]=connectPoints(dxf.points);
[path,on_off,traverse]=connectPath(dxf,seq,reverse,group);
figure; plot(path(:,1),path(:,2));
[point_3,angle,height]=convert2DPoint(path,center,radius,offset);
i=cos(angle/180*pi);
j=-sin(angle/180*pi);
k=zeros(length(angle),1);
[transformedPts,transformedNorms] = cylinderCordTrans(point_3, [i,j,k], cylinderAxis, cylinderOrin);
bcSeq=sequentialSolveBC(transformedNorms,[0,0]);
pPathSeq = [transformedPts, bcSeq];
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

