clc; close all;
% file param:
dxfFile='Drawing3.dxf';
dxf = DXFtool(dxfFile);
pFilename = strcat('./roll_',dxfFile,'_',date,'.txt');
pg = cPathGen(pFilename); % create the path generator object
pg.genNewScript();
pg.draw_ = true;
hProc = cHybridProcess(pFilename);
hProc.sPrintParam_.pFeedrate = 600; % mm/min
hProc.sPrintParam_.powderMode = 2; % both powder are used (for mixing)
hProc.sPrintParam_.pwr = 187.5;
hProc.sProcessParam_.usingRTCP = 1;
% [radius, cylinderAxis, cylinderOrin] = getCylinderParam('R.txt');
%[radius, cylinderAxis, cylinderOrin] = getCylinderParam('R.txt');
cylinderAxis = [0.00205458 0.00281062 0.99999394];
cylinderOrin = [0.89609233   2.27352335 596.64786352];
radius = 39.4197776233156;
cylinderOrin=cylinderOrin-cylinderOrin(3)/cylinderAxis(3)*cylinderAxis;
radius=radius-2;
lyrNum=4;
remelt=0;
lyrHeight=0.55;
offset=180;
center=[150,100];
[seq,reverse,group]=connectPoints(dxf.points);
[path,on_off,traverse]=connectPath(dxf,seq,reverse,group);
figure; plot(path(:,1),path(:,2));
[point_3,angle,height,on_off,traverse]=convert2DPoint(path,on_off,traverse,center,radius,offset,lyrNum,lyrHeight,remelt);
i=cos(angle/180*pi);
j=-sin(angle/180*pi);
k=zeros(length(angle),1);
[transformedPts,transformedNorms] = cylinderCordTrans(point_3, [i,j,k], cylinderAxis, cylinderOrin);
bcSeq=sequentialSolveBC(transformedNorms,[0,0]);
pPathSeq = [transformedPts, bcSeq];
pwrSeq=hProc.sPrintParam_.pwr*on_off;
feedrateSeq=hProc.sPrintParam_.pFeedrate+traverse*1000;

% generate process
hProc.sPrintParam_.flowL = 0;
hProc.sPrintParam_.speedL = 0;
hProc.sPrintParam_.flowR = 400;
hProc.sPrintParam_.speedR = 100;
% we just want to print one material, the normal printing process is enough.
% (here, one material means the single mixing ratio)
hProc.genNormalPrintingProcess(pg, pPathSeq, pwrSeq, feedrateSeq, hProc.sPrintParam_);

pg.closeScript();
pg.drawPath(pPathSeq, pPathSeq);

