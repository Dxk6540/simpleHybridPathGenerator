
% machining process param
mFeedrate = 800; % mm/min
spindleSpeed = 10000;
toolNum = 1;
toolRadiu = 4;
toolLen = 30;

%  geometry param
startCtr = [0,0];
% inclinationAgl = 0; % degree
pLyrNum = 100;
lyrHeight = 0.5;
radius = 20;
tol = 3;
safetyHeight = 230;
zOffset = 0;

side = -1; % machining inside is -1 and outside is 1
wallOffset = 1.1;
rollAgl = pi/6; %the rot angle is the angle between the tool axis and tangent
% rollAgl = 0;






%%%%%%%%%%%%%%% start %%%%%%%%%%%%%%%%%%%%



ccPt = [];
tanVec = [];
toolAxes = [];
wpHeight = pLyrNum * lyrHeight;
for curZ = 0:tol:wpHeight
    curX = vase.genVaseRadius(curZ + zOffset);
    curTan = vase.getVaseTangent(curZ + zOffset);
    ccPt = [ccPt; curX + wallOffset*side, curZ + zOffset];
    tanVec = [tanVec;curTan];

    tlAx = getToolAxis(tanVec, rollAgl, side);
end

ax = gca;
drawProfile(ax, ccPt)
drawTools(ax, ccPt, tlAx, toolRadiu, toolLen, side)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function drawProfile(ax, pos)
    plot(ax, pos(:,1), pos(:,2), '*r')
    hold on
    plot(ax, -pos(:,1), pos(:,2), '*r')
    hold on
    axis equal
    ccPt = pos;
end


function drawTools(ax, ccPt, toolAxis, toolRad, toolLen, side)
%     tanVecLen  = 40;
    for i = 1:length(toolAxis)
        p0 = ccPt(i,:);
        curToolAxis = toolAxis(i,:); 
        pe = p0 + toolLen*curToolAxis;
        plot(ax, [p0(1), pe(1)], [p0(2), pe(2)])
        hold on    
        rect = getToolRect(p0, curToolAxis, toolRad, toolLen, side);
        drawRect(ax, rect);
%         pause
    end
end

function drawRect(ax, rect)
    for i = 1:4
        plot(ax, [rect(i,1), rect(i+1,1)], [rect(i,2), rect(i+1,2)])
        hold on           
    end
end

function toolAxis = getToolAxis(tanVec, rollAgl, side)
        toolAxis = (rot2(side * -rollAgl) * tanVec')';
end

function rect = getToolRect(ccPt, toolAxis, toolRad, toolLen, side)
        vert = (rot2(pi/2) * toolAxis')';
        toolEdge2 = ccPt - side * vert * toolRad * 2;
        upToolEdge = ccPt + toolAxis*toolLen;
        upToolEdge2 = toolEdge2 + toolAxis*toolLen;     
        rect = [ccPt; toolEdge2; upToolEdge2; upToolEdge; ccPt];
end

