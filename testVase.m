% file param:
clc
clear
close all

pFilename = strcat('./cylinderTest',date,'.txt');
mFilename = strcat('./cylinderTestMachinig',date,'.txt');

% printing process param
pwr = 300; % 1.2KW / 4kw *1000;
lenPos = 900;
flowL = 250; % 6 L/min / 20L/min * 1000;
speedL = 100;% 2 r/min / 10r/min * 1000;
flowR = 250;% 6 L/min / 20L/min * 1000;
speedR = 100;% 2 r/min / 10r/min * 1000;
pFeedrate = 600; % mm/min
channel = 2;
step = 1;

% machining process param
mFeedrate = 800; % mm/min
spindleSpeed = 10000;
toolNum = 1;
toolRadiu = 4;

%  geometry param
startCtr = [0,0];
% inclinationAgl = 0; % degree
pLyrNum = 50;
lyrHeight = 0.5;
radius = 20;
tol = 0.5;
safetyHeight = 230;
zOffset = 0;

side = -1; % machining inside is -1 and outside is 1
wallOffset = 3.1;
rollAgl = pi/6; %the rot angle is the angle between the tool axis and tangent
% rollAgl = 0;

wpHeight = pLyrNum * lyrHeight;
% zOffset = 60;
[printPathSeq,pwrSeq] = vase.genPrintingPath(radius, startCtr, tol, pLyrNum, lyrHeight, pwr, zOffset, channel, step);


[toolContactPts, toolCntrPts, toolAxisSeq, fcNormalSeq] = vase.genMachiningPath(radius, startCtr, tol, wpHeight, lyrHeight, toolRadiu, wallOffset, zOffset, rollAgl, side);

figure()
scatter3(printPathSeq(1:10:end,1), printPathSeq(1:10:end,2), printPathSeq(1:10:end,3),2)
hold on
scatter3(toolContactPts(1:10:end,1), toolContactPts(1:10:end,2), toolContactPts(1:10:end,3),1)


hold on
ax = gca;
drawTools(ax, toolCntrPts, toolAxisSeq, 100);
axis equal


bcSeq = sequentialSolveBC(toolAxisSeq, [0,0]);
figure()
plot(bcSeq(:,1))
figure()
plot(bcSeq(:,2))


function drawTools(ax, origPosSeq, toolAxisSeq, step)
    toolLen  = 25;
    for i = 1:step:length(toolAxisSeq)
        p0 = origPosSeq(i,:);
        curAxis = toolAxisSeq(i,:); 
        pe = p0 + toolLen*curAxis;
        plot3(ax, [p0(1), pe(1)], [p0(2), pe(2)], [p0(3), pe(3)])
        hold on    
    end
end

