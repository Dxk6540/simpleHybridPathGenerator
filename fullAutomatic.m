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
mFeedrate = 800; % mm/min
planarFeed = 2000;
spindleSpeed = 10000;
toolNum = 1;
toolRadiu = 4;
wallOffset = 1.1;
side = 1; % machining inside is -1 and outside is 1

%  geometry param
startCtr = [-60,0];
% inclinationAgl = 0; % degree
pLyrNum = 20;
% wpH = 10;
lyrHeight = 0.5;
radius = 20;
tol = 0.1;
safetyHeight = 230;
zOffset = 0;

% shape
handle=cylinder;

% alternative
outterWallRange = [1.5,1];
innerWallRange = [2.5,2];
alternativeNum = 1;
machiningLyrThickness = -0.1;


%%
pg = cPathGen(filename); % create the path generator object
pg.genNewScript();


zOffsetRng = [0, lyrHeight*pLyrNum*alternativeNum];
for zOffset = zOffsetRng(1): lyrHeight*pLyrNum: zOffsetRng(2)
    %%%%%%%%%%%%%% printing path
    disp("printing volume")    
    [printPathSeq,pwrSeq] = handle.genPrintingPath(radius, startCtr, tol, pLyrNum, lyrHeight, pwr, zOffset, channel, step);
    genPrintingProcess(pg, safetyHeight, printPathSeq, pwrSeq, pFeedrate);

    % % planar machining
%     disp("planar machining top")
%     depthRng = [pLyrNum * lyrHeight+zOffset+5, pLyrNum * lyrHeight+zOffset];
%     planarSideLen = radius * 2 * 1.5;
%     planarPathSeq = planarMachining(startCtr, depthRng, planarSideLen, machiningLyrThickness, toolRadiu);
%     genMachiningProcess(pg, safetyHeight, toolNum, planarPathSeq, mFeedrate);    
%     pg.drawPath(printPathSeq, planarPathSeq);
% %     pause

    disp("planar machining top")
    depthRng = [pLyrNum * lyrHeight+zOffset+3, pLyrNum * lyrHeight+zOffset];
    radiuRng = [15,25];
    planarSideLen = radius * 2 * 1.5;
    planarPathSeq = planarCircleMachining(startCtr, depthRng, radiuRng, machiningLyrThickness, toolRadiu);
%     planarPathSeq = planarMachining(startCtr, depthRng, planarSideLen, machiningLyrThickness, toolRadiu);
    genMachiningProcess(pg, safetyHeight, toolNum, planarPathSeq, planarFeed);    
    pg.drawPath(printPathSeq, planarPathSeq);
%     pause

    disp("machining outter/inner wall")
    % machining outter wall
    side = 1;
    allInnerPath = [];
    for wallOffset = outterWallRange(1): machiningLyrThickness : outterWallRange(2)
    %%%%%%%%%%%%%% machining path
        outMachiningPathSeq = handle.genMachiningPath(radius, startCtr, tol, pLyrNum * lyrHeight, lyrHeight, toolRadiu, wallOffset, zOffset, side);
        genMachiningProcess(pg, safetyHeight, toolNum, outMachiningPathSeq, mFeedrate);
        allInnerPath = [allInnerPath; outMachiningPathSeq];
    end
    % machining inner wall
    side = -1;
    allOutterPath = [];
    for wallOffset = innerWallRange(1): machiningLyrThickness : innerWallRange(2)
    %%%%%%%%%%%%%% machining path
        inMachiningPathSeq = handle.genMachiningPath(radius, startCtr, tol, pLyrNum * lyrHeight, lyrHeight, toolRadiu, wallOffset, zOffset, side);
        genMachiningProcess(pg, safetyHeight, toolNum, inMachiningPathSeq, mFeedrate);
        allOutterPath = [allOutterPath; inMachiningPathSeq];    
    end
    pg.drawPath(allOutterPath, allInnerPath);
%     pause
    disp(['cycle with offset ', num2str(zOffset), 'mm is generated']);
end



pg.closeScript();


%% printing & machining functions
function ret = planarMachining(cntr, depthRange, side, machiningLyrThickness, toolRadiu)
    lyrThickness = machiningLyrThickness;
    
    passStepOver = toolRadiu*0.8;    
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
                             xRange(1), yPos, zPos];            
        end
    end

    ret = planarPathSeq;
end







function ret = planarCircleMachining(cntr, depthRange, radiuRng, mLyrThick, toolRadiu)
    lyrThickness = mLyrThick;
    
    passStepOver = toolRadiu*0.8; 
    radiuDiffLen = abs(radiuRng(1) - radiuRng(2));
    if floor(radiuDiffLen/passStepOver) == radiuDiffLen/passStepOver
        passNum = floor(radiuDiffLen/passStepOver);            
    else
        passNum = floor(radiuDiffLen/passStepOver) + 1;    
    end
    passStepOver = radiuDiffLen / passNum;
    
    tol = 1;
    mPathSeq = [];
    for curR = radiuRng(1): passStepOver: radiuRng(2)
        % planar circle path
        lyrPtNum = floor(2 * curR * pi / tol)+1;
%         % wpHeight = lyrNum * lyrHeight;
%         if floor(wpHeight/lyrThickness) == wpHeight/lyrThickness
%             lyrNum = floor(wpHeight/lyrThickness);            
%         else
%             lyrNum = floor(wpHeight/lyrThickness) + 1;    
%         end
%         lyrHeight = wpHeight/lyrNum;
% 
% %         if zOffset > 0
% %             lyrNum = lyrNum + 6;
% %         end

        aglStep = 2 * pi / lyrPtNum;
    for zPos = depthRange(1): lyrThickness: depthRange(2)
            for j = 1 : lyrPtNum
                x = cos(aglStep * j) * curR + cntr(1);
                y = sin(aglStep * j) * curR + cntr(2);
                mPathSeq = [mPathSeq; x,y,zPos];
            end
        end       
        
    end


    ret = mPathSeq;  

end





