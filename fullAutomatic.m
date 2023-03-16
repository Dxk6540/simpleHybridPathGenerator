% shape
handle = vase;
planarMachiningDepth = 4;
outterWallMachiningWidth = 0.1;
innerWallMachiningWidth = 2.1;

% file param:
filename = strcat('./fullAutoThin',handle.shape_,date,'.txt');

% printing process param
pwr = 300; % 1.2KW / 4kw *1000;
lenPos = 900;
flowL = 250; % 6 L/min / 20L/min * 1000;
speedL = 100;% 2 r/min / 10r/min * 1000;
flowR = 250;% 6 L/min / 20L/min * 1000;
speedR = 100;% 2 r/min / 10r/min * 1000;
pFeedrate = 600; % mm/min(cylinder 600, vase 590)
channel = 2;
step = 1;

% machining process param
mFeedrate = 2000; % mm/min
planarFeed = 2000;
planarSlowFeed = 100;
spindleSpeed = 10000;
wallToolNum = 1;
wallToolRadiu = 4;
plannarToolNum = 2;
plannarToolRadiu = 3;
finishToolNum = 3;
finishToolRadiu = 5;
side = 1; % machining inside is -1 and outside is 1

%  geometry param
startCtr = [0,0];
% inclinationAgl = 0; % degree
pLyrNum = 30;
lyrHeight = 0.5;
radius = 20;
tol = 0.1;
safetyHeight = 200;
machiningLyrThickness = -0.1;

%shape control
terminalHeight = 150;
alternativeNum = 0;
sglWpHeight = lyrHeight * pLyrNum;
allWpHeight = sglWpHeight * alternativeNum;
zOffset = 0;
zOffsetRng = [zOffset, allWpHeight + zOffset];
startIdx = 9;

% alternative
outterWallRange = [outterWallMachiningWidth, 0.0];
innerWallRange = [innerWallMachiningWidth, 2];
usingRTCP = 1;
    
%%
pg = cPathGen(filename); % create the path generator object
pg.genNewScript();
pg.draw_ = false;
pg.experiment_ = false;

for zOffset = zOffsetRng(1): sglWpHeight: zOffsetRng(2)
    %%%%%%%%%%%%%% printing path 
    pg.addCmd(";;;;;start a printing process");
    tol = 0.1;
    pg.pauseProgramMust();
    [printPathSeq,pwrSeq,feedrateOffset] = handle.genPrintingPath(radius, startCtr, tol, pLyrNum, lyrHeight, pwr, zOffset, channel, step);
    genPrintingProcess(pg, safetyHeight, printPathSeq, pwrSeq, pFeedrate*feedrateOffset);

    %%%%%%%%%%%%%% rough machining path
    tol = 0.2;
    %%%%%%%%%%%%%%%%%%%%% plannar circle machining %%%%%%%%%%%%%%%%%%%%
    pg.addCmd(";;;;;start a planar machining process");
    if handle.shape_=="Vase"
        planarRadiuRng = [handle.getRadius(zOffset+sglWpHeight)-3,handle.getRadius(zOffset+sglWpHeight)+2];
    elseif handle.shape_=="Cylinder"
        planarRadiuRng = [radius-3,radius+2];
    end
    depthRng = [sglWpHeight+zOffset+planarMachiningDepth, sglWpHeight+zOffset];
    [planarPathSeq, planarFeedSeq]  = planarCircleMachining(startCtr, depthRng, planarRadiuRng, machiningLyrThickness, plannarToolRadiu, planarFeed, planarSlowFeed);
    genMachiningProcess(pg, safetyHeight, plannarToolNum, planarPathSeq, planarFeedSeq, 0, side);    
    pg.drawPath(printPathSeq, planarPathSeq);
    
    startIdx = 9;
    if zOffset + sglWpHeight >= terminalHeight
        startIdx = 0;
    end
    %%%%%%%%%%%%%%%%%%%%%%%% machining outter wall %%%%%%%%%%%%%%%%%%%%%%%%
    pg.addCmd(";;;;;start a outter wall rough machining process");
    side = 1;
    allOutterPath = [];
    for wallOffset = outterWallRange(1): machiningLyrThickness : outterWallRange(2)
    %%%%%%%%%%%%%% machining path
        outMachiningPathSeq = handle.genMachiningPath(radius, startCtr, tol, sglWpHeight, lyrHeight, wallToolRadiu, wallOffset, zOffset, side, startIdx);
        allOutterPath = [allOutterPath; outMachiningPathSeq];
    end
	genMachiningProcess(pg, safetyHeight, wallToolNum, allOutterPath, mFeedrate, usingRTCP, side);

    %%%%%%%%%%%%%%%%%%%%%%%%% machining inner wall %%%%%%%%%%%%%%%%%%%%%%%%
    pg.addCmd(";;;;;start a inner wall rough machining process");
    side = -1;
    allInnerPath = [];
    for wallOffset = innerWallRange(1): machiningLyrThickness : innerWallRange(2)
    %%%%%%%%%%%%%% machining path
        inMachiningPathSeq = handle.genMachiningPath(radius, startCtr, tol, sglWpHeight, lyrHeight, wallToolRadiu, wallOffset, zOffset, side, startIdx);
        allInnerPath = [allInnerPath; inMachiningPathSeq];   
    end
    genMachiningProcess(pg, safetyHeight, wallToolNum, allInnerPath, mFeedrate, usingRTCP, side);
    pg.addPathPt([0,0,safetyHeight,0,0]);
%    pg.drawPath(allInnerPath, allOutterPath);

%%%%%%%%%%%%%% finish machining path
    tol = 0.02;
    %%%%%%%%%%%%%%%%%%%%%%%%% machining inner wall %%%%%%%%%%%%%%%%%%%%%%%%
    pg.addCmd(";;;;;start a inner wall finish machining process");
    side = -1;
    allInnerPath = [];
    for wallOffset = innerWallRange(2)-0.02: -0.02 : innerWallRange(2)-0.04
    %%%%%%%%%%%%%% machining path
        inMachiningPathSeq = handle.genMachiningPath(radius, startCtr, tol, sglWpHeight, 0.05, finishToolRadiu, wallOffset, zOffset, side, startIdx);
        allInnerPath = [allInnerPath; inMachiningPathSeq];   
    end
    genMachiningProcess(pg, safetyHeight, finishToolNum, allInnerPath, mFeedrate, usingRTCP, side);
    pg.addPathPt([0,0,safetyHeight,0,0]);
    
    %%%%%%%%%%%%%%%%%%%%%%%% machining outter wall %%%%%%%%%%%%%%%%%%%%%%%%
    if zOffset + sglWpHeight >= terminalHeight
        pg.addCmd(";;;;;start a outter wall rough machining process");
        side = 1;
        allOutterPath = [];
        for wallOffset = outterWallRange(2)-0.02: 0.02 : outterWallRange(2)-0.04
        %%%%%%%%%%%%%% machining path
            outMachiningPathSeq = handle.genMachiningPath(radius, startCtr, tol, terminalHeight, 0.05, finishToolRadiu, wallOffset, 0, side, startIdx);
            allOutterPath = [allOutterPath; outMachiningPathSeq];
        end
        genMachiningProcess(pg, safetyHeight, finishToolNum, allOutterPath, mFeedrate, usingRTCP, side);
    end
        
    disp(['cycle with offset ', num2str(zOffset), 'mm is generated']);
    pg.alternation_ = pg.alternation_ + 1;
end

pg.closeScript();