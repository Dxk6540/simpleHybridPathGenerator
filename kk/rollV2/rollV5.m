
clc; close all;
addpath('../../lib')

% file param:
% partIdx = P1
dxfFile='sample0521/P1.dxf';
pFilename = strcat('./rollAllProc_','P1','_',date,'.txt');
% following: process parameters
hProc = cHybridProcess(pFilename);
hProc.sPrintParam_.pFeedrate = 900; % mm/min
% hProc.sPrintParam_.powderMode = 3; % both powder are used (for mixing)
hProc.sPrintParam_.powderMode = 2; % 1 = left, 2 = right, 3 = left + right
hProc.sPrintParam_.pwr = 275;
hProc.sPrintParam_.lenPos = 600;
hProc.sProcessParam_.usingRTCP = 1;
hProc.sPrintParam_.flowL = 0;
hProc.sPrintParam_.speedL = 0;
hProc.sPrintParam_.flowR = 400;
hProc.sPrintParam_.speedR = 100;
hProc.airRun_ = 0; % 1 for trail Run
lyrHeight=0.4;
preheat=1;
remelt=0;

% following: geometry parameters
cylinderAxis = [3.85670648e-04 -3.59079724e-05 -9.99999925e-01];
% cylinderAxis = [0 0 1];
cylinderAxisPt = [-0.57349023  -0.5134414  125.78922542];

radius = 39.4271843401534; % CMM radius
% radius = 39.251879512093094;
% radius = 40.161879512093094;
rollerTipHeight = 2;
finalRadius = 39.6;
% finalRadius = radius + rollerTipHeight;
adaptiveLyrNum = 1;

offset=0;
center=[153.71,0]; % axial start point,  radial start point
lyrNum=3;
margin = [0,0];


                % flowL, speedL, flowR, speedR 
% procParamMatrix = [250, 100, 400, 0;
%                    250, 75, 400, 25;
%                    250, 50, 400, 50;
%                    250, 25, 400, 75;
%                    250, 0, 400, 100;];
motherProcParam = [0,0,400,100];
procParamMatrix = repmat(motherProcParam,[lyrNum,1]);



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
if cylinderAxis(3) < 0
    cylinderAxis = - cylinderAxis;
end


disp(strcat('command lyrNum: ', num2str(lyrNum)));
actRadius = radius - 2; % minus a radiu of probe

if adaptiveLyrNum == 1
    estLyrNum = round((finalRadius - actRadius)/lyrHeight);
    if lyrHeight*estLyrNum < finalRadius - actRadius
        estLyrNum = estLyrNum + 1;
    end
    disp(strcat('estimated lyrNum: ', num2str(estLyrNum)));
    lyrNum = estLyrNum;
    procParamMatrix = repmat(motherProcParam,[lyrNum,1]);
else
    lyrNum = lyrNum;
end
disp(strcat('actRadius: ', num2str(actRadius), '  finalRadius: ', num2str(finalRadius)));

radiusList = [actRadius];
for i = 1:(lyrNum - 1)
    radiusList = [radiusList, actRadius+i*lyrHeight];    
end    

disp(strcat('per layer radius: ', num2str(radiusList)));
disp(strcat('last pattern radius: ', num2str(actRadius+lyrNum*lyrHeight)));

[agl,height] = cylinderMapping(path,center, finalRadius, offset);
procLyr = cell(lyrNum, 4);
for i = 1:lyrNum
    [point_3,ori_3] = cylinderCord2CartesianCord(agl,height,radiusList(i));
    
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
% procLyr = flipud(procLyr);

if preheat == 1
    preHeatLyr = cell(1, 4);
    [prePoint_3,preOri_3] = cylinderCord2CartesianCord(agl,height,radiusList(1));
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
