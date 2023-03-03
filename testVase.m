% file param:
pFilename = strcat('./cylinderTest',date,'.txt');
mFilename = strcat('./cylinderTestMachinig',date,'.txt');

% process param
% pwr = 300; % 1.2KW / 4kw *1000;
% lenPos = 900;
% flowL = 300; % 6 L/min / 20L/min * 1000;
% speedL = 200;% 2 r/min / 10r/min * 1000;
% flowR = 300;% 6 L/min / 20L/min * 1000;
% speedR = 200;% 2 r/min / 10r/min * 1000;
% feedrate = 760; % mm/min

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
wallOffset = 1.1;
side = -1; % machining inside is -1 and outside is 1

%  geometry param
startCtr = [0,0];
% inclinationAgl = 0; % degree
pLyrNum = 5;
lyrHeight = 4;
radius = 20;
tol = 20;
safetyHeight = 230;
zOffset = 0;


wpHeight = pLyrNum * lyrHeight;
% zOffset = 60;
[printPathSeq,pwrSeq] = vase.genPrintingPath(radius, startCtr, tol, pLyrNum, lyrHeight, pwr, zOffset, channel, step);
rollAgl = pi/6;
rollAgl = 0;
[toolContactPts, toolCntrPts, toolAxisSeq, fcNormalSeq] = vase.genMachiningPath(radius, startCtr, tol, wpHeight, lyrHeight, toolRadiu, wallOffset, zOffset, rollAgl, side);

figure()
scatter3(printPathSeq(1:10:end,1), printPathSeq(1:10:end,2), printPathSeq(1:10:end,3),2)
hold on
scatter3(toolContactPts(1:10:end,1), toolContactPts(1:10:end,2), toolContactPts(1:10:end,3),1)

% pos = [];
% tanVec = [];
% for curZ = 0:5:wpHeight
%     curX = vase.genVaseRadius(curZ);
%     curTan = vase.getVaseTangent(curZ);
%     pos = [pos; curX, curZ];
%     tanVec = [tanVec;curTan];
% end
% 
% plot(xPos, zPos)
% hold on
% plot(-xPos, zPos)
% >>>>>>> d4795cec086837ff6e45786c567666713af48592
hold on
ax = gca;
drawTools(ax, toolCntrPts, toolAxisSeq);
% hold on
% drawTools(ax, toolContactPts, toolAxisSeq);

function drawTools(ax, origPosSeq, toolAxisSeq)
    toolLen  = 40;
    for i = 1:length(toolAxisSeq)
        p0 = origPosSeq(i,:);
        curAxis = toolAxisSeq(i,:); 
        pe = p0 + toolLen*curAxis;
        plot3(ax, [p0(1), pe(1)], [p0(2), pe(2)], [p0(3), pe(3)])
        hold on    
%         rect = getToolRect(p0, curAxis, 4, 50);
%         drawRect(ax, rect);
%         pause
    end
end


% %%%%%%%%%%%%%%% follow  for 2D %%%%%%%%%%%%%%
% pos = [];
% tanVec = [];
% for curZ = 0:5:wpHeight
%     curX = vase.genVaseRadius(curZ);
%     curTan = vase.getVaseTangent(curZ);
%     pos = [pos; curX, curZ];
%     tanVec = [tanVec;curTan];
% end
% 
% plot(xPos, zPos)
% hold on
% plot(-xPos, zPos)
% hold on
% ax = gca;
% axis equal
% 
% drawTanVec(ax, pos, tanVec)
% 
% function drawTanVec(ax, origPos, tanVec)
%     tanVecLen  = 40;
%     for i = 1:length(tanVec)
%         p0 = origPos(i,:);
%         curTan = tanVec(i,:); 
%         pe = p0 + tanVecLen*curTan;
%         plot(ax, [p0(1), pe(1)], [p0(2), pe(2)])
%         hold on    
%         rect = getToolRect(p0, curTan, 4, 50);
%         drawRect(ax, rect);
%         pause
%     end
% end
% 
% function drawRect(ax, rect)
%     for i = 1:4
%         plot(ax, [rect(i,1), rect(i+1,1)], [rect(i,2), rect(i+1,2)])
%         hold on           
%     end
% end
% 
% function rect = getToolRect(pos, vec, toolRad, toolLen, side)
%         toolContactPt = pos;
% %         vert = rot90(vec)';
%         vert = (rot2(pi/2) * vec')';
%         toolEdge2 = toolContactPt + vert * toolRad * 2;
%         upToolEdge = toolContactPt + vec*toolLen;
%         upToolEdge2 = toolEdge2 + vec*toolLen;     
%         rect = [toolContactPt; toolEdge2; upToolEdge2; upToolEdge; toolContactPt];
% end

