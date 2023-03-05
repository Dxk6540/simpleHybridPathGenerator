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
pFeedrate = 620; % mm/min(cylinder 600, vase 590)
channel = 2;
step = 1;

% machining process param
mFeedrate = 1200; % mm/min
planarFeed = 1200;
planarSlowFeed = 300;
spindleSpeed = 10000;
wallToolNum = 1;
wallToolRadiu = 4;
plannarToolNum = 2;
plannarToolRadiu = 3;
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
planarMachiningDepth = 4;
sglWpHeight = lyrHeight * pLyrNum;
allWpHeight = sglWpHeight * alternativeNum;
zOffsetRng = [15, allWpHeight+15];

% alternative
outterWallRange = [1.2,0.4];
innerWallRange = [2.6,2.1];
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
    [printPathSeq,pwrSeq,feedrateOffset] = handle.genPrintingPath(radius, startCtr, tol, pLyrNum, lyrHeight, pwr, zOffset, channel, step);
    genPrintingProcess(pg, safetyHeight, printPathSeq, pwrSeq, pFeedrate*feedrateOffset);

    %%%%%%%%%%%%%%%%%%%%% plannar circle machining %%%%%%%%%%%%%%%%%%%%
    pg.addCmd(";;;;;start a planar machining process");
    tol = 0.2;
    if handle.shape_=="Vase"
        planarRadiuRng = [handle.getRadius(zOffset+sglWpHeight)-3,handle.getRadius(zOffset+sglWpHeight)+2];
    elseif handle.shape_=="Cylinder"
        planarRadiuRng = [radius-3,radius+2];
    end
    depthRng = [sglWpHeight+zOffset+planarMachiningDepth, sglWpHeight+zOffset];
    [planarPathSeq, planarFeedSeq]  = planarCircleMachining(startCtr, depthRng, planarRadiuRng, machiningLyrThickness, plannarToolRadiu, planarFeed, planarSlowFeed);
    genMachiningProcess(pg, safetyHeight, plannarToolNum, planarPathSeq, planarFeedSeq, 0, side);    
    pg.drawPath(printPathSeq, planarPathSeq);
    
    %%%%%%%%%%%%%%%%%%%%%%%%% machining outter wall %%%%%%%%%%%%%%%%%%%%%%%%
    pg.addCmd(";;;;;start a outter wall machining process");
    side = 1;
    allOutterPath = [];
    for wallOffset = outterWallRange(1): machiningLyrThickness : outterWallRange(2)
    %%%%%%%%%%%%%% machining path
        outMachiningPathSeq = handle.genMachiningPath(radius, startCtr, tol, sglWpHeight, lyrHeight, wallToolRadiu, wallOffset, zOffset, side);
        allOutterPath = [allOutterPath; outMachiningPathSeq];
    end
	genMachiningProcess(pg, safetyHeight, wallToolNum, allOutterPath, mFeedrate, usingRTCP, side);

    %%%%%%%%%%%%%%%%%%%%%%%%% machining inner wall %%%%%%%%%%%%%%%%%%%%%%%%
    pg.addCmd(";;;;;start a inner wall machining process");
    side = -1;
    allInnerPath = [];
    for wallOffset = innerWallRange(1): machiningLyrThickness : innerWallRange(2)
    %%%%%%%%%%%%%% machining path
        inMachiningPathSeq = handle.genMachiningPath(radius, startCtr, tol, sglWpHeight, lyrHeight, wallToolRadiu, wallOffset, zOffset, side);
        allInnerPath = [allInnerPath; inMachiningPathSeq];   
    end
    genMachiningProcess(pg, safetyHeight, wallToolNum, allInnerPath, mFeedrate, usingRTCP, side);
    pg.addPathPt([0,0,safetyHeight,0,0]);
    pg.drawPath(allInnerPath, allOutterPath);

    disp(['cycle with offset ', num2str(zOffset), 'mm is generated']);
    pg.alternation_ = pg.alternation_ + 1;
end

pg.closeScript();