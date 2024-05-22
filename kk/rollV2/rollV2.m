
clc; close all;
addpath('../../lib')

% file param:
% partIdx = P1
dxfFile='sample0521/P2R.dxf';
pFilename = strcat('./rollAllProc_','P2R','_',date,'.txt');
% following: process parameters
hProc = cHybridProcess(pFilename);
hProc.sPrintParam_.pFeedrate = 600; % mm/min
hProc.sPrintParam_.powderMode = 2; % both powder are used (for mixing)
hProc.sPrintParam_.pwr = 187.5;
hProc.sPrintParam_.lenPos = 600;
hProc.sProcessParam_.usingRTCP = 1;
hProc.sPrintParam_.flowL = 0;
hProc.sPrintParam_.speedL = 0;
hProc.sPrintParam_.flowR = 400;
hProc.sPrintParam_.speedR = 100;
hProc.airRun_ = 0; % 1 for trail Run
lyrHeight=0.475;
preheat=1;
remelt=0;

% following: geometry parameters
cylinderAxis = [-1.25002845e-03 -7.07039960e-04  9.99998969e-01];
cylinderAxisPt = [-4.16141539e-01 -4.94402528e-01  4.41467132e+02];
radius = 35.7023043279201;
% radius = 41.75119029240845;

offset=0;
center=[150,0]; % axial start point,  radial start point
lyrNum=5;
margin = [0,0];


% gen 2D file path
dxf = DXFtool(dxfFile); % read DXF
[seq,reverse,group] = connectPoints(dxf.points);
[path,on_off,traverse] = connectPath(dxf,seq,reverse,group);
offsetDxf = [min(path(:,1)), min(path(:,2))]-margin;
path = path - offsetDxf;
maxDxf = [max(path(:,1)), max(path(:,2))]
figure; plot(path(:,1),path(:,2));

% gen printing 3D path
cylinderAxis = cylinderAxis/norm(cylinderAxis);
cylinderOrin = cylinderAxisPt - cylinderAxisPt(3)/cylinderAxis(3)*cylinderAxis;
radius = radius-2; % minus a radiu of probe
% [point_3,angle,height,on_off,traverse] = convert2DPoint(path,on_off,traverse,center,radius,offset,lyrNum,lyrHeight,remelt);
[point_3,ori_3,height,pOn_off,pTraverse] = convert2DPoint(path,on_off,traverse,center,radius,offset,lyrNum,lyrHeight,remelt, preheat);
[transformedPts, transformedNorms] = cylinderCordTrans(point_3, ori_3, cylinderAxis, cylinderOrin);
bcSeq = sequentialSolveBC(transformedNorms,[0,0]);
pPathSeq = [transformedPts, bcSeq];
pwrSeq = hProc.sPrintParam_.pwr*pOn_off;
feedrateSeq=hProc.sPrintParam_.pFeedrate+pTraverse*1000;

if preheat == 1
    [prePoint_3,preOri_3,preH,preOn_off,preTraverse] = convert2DPoint(path,on_off,traverse,center,radius,offset,1,lyrHeight,remelt, preheat);
    [preTransformedPts, preTransformedNorms] = cylinderCordTrans(prePoint_3, preOri_3, cylinderAxis, cylinderOrin);
    preBcSeq = sequentialSolveBC(preTransformedNorms,[0,0]);
    prePathSeq = [preTransformedPts, preBcSeq];
    prePwrSeq = hProc.sPrintParam_.pwr*preOn_off;
    preFeedrateSeq=hProc.sPrintParam_.pFeedrate+preTraverse*1000;    
end


% generate process
pg = cPathGen(pFilename); % create the path generator object
pg.genNewScript();
pg.draw_ = true;
if preheat == 1
    processCells= cell(2, 4);
    processCells{1,1} = prePathSeq;
    processCells{1,2} = prePwrSeq;
    processCells{1,3} = preFeedrateSeq;
    processCells{1,4} = [hProc.sPrintParam_.flowL, 0, hProc.sPrintParam_.flowR, 0];% flowL, speedL, flowR, speedR  

    processCells{2,1} = pPathSeq;
    processCells{2,2} = pwrSeq;
    processCells{2,3} = feedrateSeq;
    processCells{2,4} = [hProc.sPrintParam_.flowL,hProc.sPrintParam_.speedL, hProc.sPrintParam_.flowR, hProc.sPrintParam_.speedR];% flowL, speedL, flowR, speedR        
else
    processCells= cell(1, 4);    
    processCells{1,1} = pPathSeq;
    processCells{1,2} = pwrSeq;
    processCells{1,3} = feedrateSeq;
    processCells{1,4} = [hProc.sPrintParam_.flowL,hProc.sPrintParam_.speedL, hProc.sPrintParam_.flowR, hProc.sPrintParam_.speedR];% flowL, speedL, flowR, speedR                                 
end

hProc.genRollerPrintingProcess(pg, processCells, [0,0,0], hProc.sPrintParam_);

pg.closeScript();
pg.drawPath(pPathSeq, pPathSeq);

