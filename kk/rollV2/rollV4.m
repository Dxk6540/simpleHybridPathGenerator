
clc; close all;
addpath('../../lib')

% file param:
% partIdx = P1
dxfFile='sample0521/P1.dxf';
pFilename = strcat('./rollAllProc_','P1','_',date,'.txt');
% following: process parameters
hProc = cHybridProcess(pFilename);
hProc.sPrintParam_.pFeedrate = 400; % mm/min
hProc.sPrintParam_.powderMode = 3; % both powder are used (for mixing)
hProc.sPrintParam_.pwr = 208.3334;
hProc.sPrintParam_.lenPos = 600;
hProc.sProcessParam_.usingRTCP = 1;
hProc.sPrintParam_.flowL = 0;
hProc.sPrintParam_.speedL = 0;
hProc.sPrintParam_.flowR = 400;
hProc.sPrintParam_.speedR = 100;
hProc.airRun_ = 0; % 1 for trail Run
lyrHeight=-0.68;
preheat=1;
remelt=0;

                % flowL, speedL, flowR, speedR 
% procParamMatrix = [250, 100, 400, 0;
%                    250, 75, 400, 25;
%                    250, 50, 400, 50;
%                    250, 25, 400, 75;
%                    250, 0, 400, 100;];
% procParamMatrix = [250, 100, 400, 0;
%                    250, 50, 400, 50;
%                    250, 0, 400, 100];
procParamMatrix = [250, 0, 400, 100;
                   250, 50, 400, 50;
                   250, 100, 400, 0;];

% following: geometry parameters
cylinderAxis = [5.67515150e-04 -1.12342462e-03  9.99999208e-01];
% cylinderAxis = [0 0 1];
cylinderAxisPt = [3.12087160e+01 -6.04615482e+01  5.40207016e+04];
radius = 40.161879512093094;
% radius = 41.75119029240845;
% radius = 39.8;

offset=0;
center=[149,0]; % axial start point,  radial start point
lyrNum=3;
margin = [0,0];


% gen 2D file path
dxf = DXFtool(dxfFile); % read DXF
[seq,reverse,group] = connectPoints(dxf.points);
[path,on_off,traverse] = connectPath(dxf,seq,reverse,group);
offsetDxf = [min(path(:,1)), min(path(:,2))]-margin;
path = path - offsetDxf;
maxDxf = [max(path(:,1)), max(path(:,2))]
figure; plot(path(:,1),path(:,2));
[path,on_off,traverse] = pt2dTraverse(path,on_off,traverse);

% gen printing 3D path
cylinderAxis = cylinderAxis/norm(cylinderAxis);
cylinderOrin = cylinderAxisPt - cylinderAxisPt(3)/cylinderAxis(3)*cylinderAxis;
radius = radius-2; % minus a radiu of probe
radius = radius + 2;

procLyr = cell(lyrNum, 4);
for i = 1:lyrNum
    [point_3,ori_3,height] = convert2DPoint(path,center,radius,offset,lyrHeight,i);
    [transformedPts, transformedNorms] = cylinderCordTrans(point_3, ori_3, cylinderAxis, cylinderOrin);
    bcSeq = sequentialSolveBC(transformedNorms,[0,0]);
    pPathSeq = [transformedPts, bcSeq];
    pwrSeq = hProc.sPrintParam_.pwr*on_off;
    feedrateSeq=hProc.sPrintParam_.pFeedrate+traverse*1000;
    procLyr{i,1} = pPathSeq;
    procLyr{i,2} = pwrSeq;
    procLyr{i,3} = feedrateSeq;
%     procLyr{i,4} = [hProc.sPrintParam_.flowL,hProc.sPrintParam_.speedL, hProc.sPrintParam_.flowR, hProc.sPrintParam_.speedR];% flowL, speedL, flowR, speedR            
    procLyr{i,4} = procParamMatrix(i,:);% flowL, speedL, flowR, speedR            
end
procLyr = flipud(procLyr);

if preheat == 1
    preHeatLyr = cell(1, 4);
%     [prePoint_3,preOri_3,preH,preOn_off,preTraverse] = convert2DPoint(path,on_off,traverse,center,radius,offset,1,lyrHeight,remelt, preheat);
    [prePoint_3,preOri_3,preH] = convert2DPoint(path,center,radius,offset,lyrHeight,1);
    [preTransformedPts, preTransformedNorms] = cylinderCordTrans(prePoint_3, preOri_3, cylinderAxis, cylinderOrin);
    preBcSeq = sequentialSolveBC(preTransformedNorms,[0,0]);
    prePathSeq = [preTransformedPts, preBcSeq];
    prePwrSeq = hProc.sPrintParam_.pwr*on_off;
    preFeedrateSeq=hProc.sPrintParam_.pFeedrate+traverse*1000;    
    preHeatLyr{1,1} = prePathSeq;
    preHeatLyr{1,2} = prePwrSeq;
    preHeatLyr{1,3} = preFeedrateSeq;
    preHeatLyr{1,4} = [hProc.sPrintParam_.flowL, 0, hProc.sPrintParam_.flowR, 0];% flowL, speedL, flowR, speedR  
    
end


% generate process
pg = cPathGen(pFilename); % create the path generator object
pg.genNewScript();
pg.draw_ = true;
if preheat == 1
    processCells = [preHeatLyr; procLyr];
else
    processCells = procLyr;
end

hProc.genRollerPrintingProcess(pg, processCells, [0,0,0], hProc.sPrintParam_);

pg.closeScript();
drawAllPath(processCells)


function drawAllPath(procs)
    figure();
    for i = 1:length(procs)
        plot3(procs{i,1}(:,1),procs{i,1}(:,2),procs{i,1}(:,3));
        hold on
    end
    axis equal;

end
