% shape
handle = vase;

% file param:
filename = strcat('./fullAuto',handle.shape_,date,'.txt');

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
planarFeed = 400;
planarSlowFeed = 200;
spindleSpeed = 10000;
toolNum = 1;
toolRadiu = 4;
side = 1; % machining inside is -1 and outside is 1

%  geometry param
startCtr = [0,0];
% inclinationAgl = 0; % degree
pLyrNum = 30;
lyrHeight = 0.5;
radius = 20;
tol = 0.1;
safetyHeight = 200;
alternativeNum = 1;
machiningLyrThickness = -0.1;
planarMachiningDepth = 3;
sglWpHeight = lyrHeight * pLyrNum;
allWpHeight = sglWpHeight * alternativeNum;
zOffsetRng = [0, allWpHeight];

% alternative
outterWallRange = [1.2,0.4];
innerWallRange = [2.6,2.1];
    
%%
pg = cPathGen(filename); % create the path generator object
pg.genNewScript();
pg.draw_ = false;
pg.experiment_ = false;

zOffsetRng = [0, lyrHeight*pLyrNum*alternativeNum];

for zOffset = zOffsetRng(1): sglWpHeight: zOffsetRng(2)
    %%%%%%%%%%%%%% printing path 
    tol = 0.1;
    [printPathSeq,pwrSeq] = handle.genPrintingPath(radius, startCtr, tol, pLyrNum, lyrHeight, pwr, zOffset, channel, step);
    genPrintingProcess(pg, safetyHeight, printPathSeq, pwrSeq, pFeedrate);

    %%%%%%%%%%%%%%%%%%%%% plannar circle machining %%%%%%%%%%%%%%%%%%%%
    tol = 0.2;
    planarRadiuRng = [handle.getRadius(zOffset+sglWpHeight)-3,handle.getRadius(zOffset+sglWpHeight)+2];
    depthRng = [sglWpHeight+zOffset+planarMachiningDepth, sglWpHeight+zOffset];
    [planarPathSeq, planarFeedSeq]  = planarCircleMachining(startCtr, depthRng, planarRadiuRng, machiningLyrThickness, toolRadiu, planarFeed, planarSlowFeed);
    genMachiningProcess(pg, safetyHeight, toolNum, planarPathSeq, planarFeedSeq);    
    pg.drawPath(printPathSeq, planarPathSeq);
    
    %%%%%%%%%%%%%%%%%%%%%%%%% machining outter wall %%%%%%%%%%%%%%%%%%%%%%%%
    side = 1;
    allOutterPath = [];
    for wallOffset = outterWallRange(1): machiningLyrThickness : outterWallRange(2)
    %%%%%%%%%%%%%% machining path
        outMachiningPathSeq = handle.genMachiningPath(radius, startCtr, tol, sglWpHeight, lyrHeight, toolRadiu, wallOffset, zOffset, side);
        allOutterPath = [allOutterPath; outMachiningPathSeq];
    end
    pg.startRTCP(safetyHeight, toolNum);
	genMachiningProcess(pg, safetyHeight, toolNum, allOutterPath, mFeedrate);
%     % machining inner wall
    side = -1;
    allInnerPath = [];
    for wallOffset = innerWallRange(1): machiningLyrThickness : innerWallRange(2)
    %%%%%%%%%%%%%% machining path
        inMachiningPathSeq = handle.genMachiningPath(radius, startCtr, tol, sglWpHeight, lyrHeight, toolRadiu, wallOffset, zOffset, side);
        allInnerPath = [allInnerPath; inMachiningPathSeq];   
    end
    genMachiningProcess(pg, safetyHeight, toolNum, allInnerPath, mFeedrate);
    pg.stopRTCP(safetyHeight);
    pg.addPathPt([0,0,safetyHeight,0,0]);
    pg.drawPath(allInnerPath, allOutterPath);

    disp(['cycle with offset ', num2str(zOffset), 'mm is generated']);
    pg.alternation_ = pg.alternation_ + 1;
end

pg.closeScript();