% file param:
filename = strcat('./fullAutoCylinderTest',date,'.txt');

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
mFeedrate = 300; % mm/min
planarFeed = 300;
spindleSpeed = 10000;
toolNum = 1;
toolRadiu = 4;
wallOffset = 1.1;
side = 1; % machining inside is -1 and outside is 1

%  geometry param
startCtr = [60,0];
% inclinationAgl = 0; % degree
pLyrNum = 30;
lyrHeight = 0.5;
radius = 20;
tol = 0.1;
safetyHeight = 230;

% shape
handle=cylinder;

% alternative
outterWallRange = [1.2,0.4];
innerWallRange = [2.6,2.1];

alternativeNum = 1;
machiningLyrThickness = -0.1;
planarMachiningDepth = 3;
planarRadiuRng = [18,24];
    
%%
sglWpHeight = lyrHeight * pLyrNum;
allWpHeight = sglWpHeight * alternativeNum;
zOffsetRng = [0, allWpHeight];

pg = cPathGen(filename); % create the path generator object
pg.genNewScript();
pg.draw_ = false;
pg.experiment_ = false;
pg.alternation_ = 1;

zOffsetRng = [0, lyrHeight*pLyrNum*alternativeNum];

for zOffset = zOffsetRng(1): sglWpHeight: zOffsetRng(2)
    %%%%%%%%%%%%%% printing path
    disp("printing volume")    
    [printPathSeq,pwrSeq] = handle.genPrintingPath(radius, startCtr, tol, pLyrNum, lyrHeight, pwr, zOffset, channel, step);
    genPrintingProcess(pg, safetyHeight, printPathSeq, pwrSeq, pFeedrate);

    %%%%%%%%%%%%%%%%%%%%% plannar circle machining %%%%%%%%%%%%%%%%%%%%
    disp("planar machining top")
    depthRng = [sglWpHeight+zOffset+planarMachiningDepth, sglWpHeight+zOffset];
%     planarSide = 50;
%     planarPathSeq = planarMachining(startCtr, depthRng, planarSide, machiningLyrThickness, toolRadiu);
    planarPathSeq = planarCircleMachining(startCtr, depthRng, planarRadiuRng, machiningLyrThickness, toolRadiu);
    genMachiningProcess(pg, safetyHeight, toolNum, planarPathSeq, planarFeed);    
    pg.drawPath(printPathSeq, planarPathSeq);
    
    disp("machining outter/inner wall")
    %%%%%%%%%%%%%%%%%%%%%%%%% machining outter wall %%%%%%%%%%%%%%%%%%%%%%%%
    side = 1;
    allOutterPath = [];
    for wallOffset = outterWallRange(1): machiningLyrThickness : outterWallRange(2)
    %%%%%%%%%%%%%% machining path
        outMachiningPathSeq = handle.genMachiningPath(radius, startCtr, tol, sglWpHeight, lyrHeight, toolRadiu, wallOffset, zOffset, side);
        allOutterPath = [allOutterPath; outMachiningPathSeq];
    end
	genMachiningProcess(pg, safetyHeight, toolNum, allOutterPath, mFeedrate);
    % machining inner wall
    side = -1;
    allInnerPath = [];
    for wallOffset = innerWallRange(1): machiningLyrThickness : innerWallRange(2)
    %%%%%%%%%%%%%% machining path
        inMachiningPathSeq = handle.genMachiningPath(radius, startCtr, tol, sglWpHeight, lyrHeight, toolRadiu, wallOffset, zOffset, side);
        allInnerPath = [allInnerPath; inMachiningPathSeq];   
    end
    genMachiningProcess(pg, safetyHeight, toolNum, allInnerPath, mFeedrate);
    pg.drawPath(allInnerPath, allOutterPath);
%     pause
    disp(['cycle with offset ', num2str(zOffset), 'mm is generated']);
    pg.alternation_ = pg.alternation_ + 1;
end



pg.closeScript();


%% printing & machining functions
function ret = planarMachining(cntr, depthRange, side, machiningLyrThickness, toolRadiu)
    lyrThickness = machiningLyrThickness;
    
    passStepOver = toolRadiu*3.5;    
    if floor(side/passStepOver) == side/passStepOver
        passNum = floor(side/passStepOver);            
    else
        passNum = floor(side/passStepOver) + 1;    
    end
    passStepOver = side / passNum;
    
    xRange = [cntr(1) - side/2, cntr(1) + side/2];
    yRange = [cntr(2) - side/2, cntr(2) + side/2];
    planarPathSeq = [];    
    for zPos = depthRange(1): lyrThickness: depthRange(2)
        for yPos = yRange(1): passStepOver: yRange(2)
            planarPathSeq = [planarPathSeq; 
                             xRange(1), yPos, zPos;
                             xRange(2), yPos, zPos;
                             xRange(2), yPos + passStepOver/2, zPos;                             
                             xRange(1), yPos + passStepOver/2, zPos];            
        end
    end

    ret = planarPathSeq;
end


function ret = planarCircleMachining(cntr, depthRange, radiuRng, mLyrThick, toolRadiu)
    lyrThickness = mLyrThick;
    
    passStepOver = toolRadiu*1.6; 
    radiuDiffLen = abs(radiuRng(1) - radiuRng(2));
    if floor(radiuDiffLen/passStepOver) == radiuDiffLen/passStepOver
        passNum = floor(radiuDiffLen/passStepOver);            
    else
        passNum = floor(radiuDiffLen/passStepOver) + 1;    
    end
    passStepOver = radiuDiffLen / passNum;    
    tol = 1;
    mPathSeq = [];
    for zPos = depthRange(1): lyrThickness: depthRange(2)    
        for curR = radiuRng(1): passStepOver: radiuRng(2)
            % planar circle path
            lyrPtNum = floor(2 * curR * pi / tol)+1;
            aglStep = 2 * pi / lyrPtNum;
            for j = 1 : lyrPtNum
                x = cos(aglStep * j) * curR + cntr(1);
                y = sin(aglStep * j) * curR + cntr(2);
                mPathSeq = [mPathSeq; x,y,zPos];
            end
        end               
    end
    ret = mPathSeq;  
end





