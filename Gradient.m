% shape
handle = cube;
planarMachiningDepth = 1;
outterWallMachiningWidth = 1;

% file param:
filename = strcat('./fullAutoThinTest',handle.shape_,date,'.txt');

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

%  geometry param
startCtr = [0,60];
% inclinationAgl = 0; % degree
pLyrNum = 5;
lyrHeight = 0.5;
cubeLength = 30;
tol = 0.1;
safetyHeight = 200;
machiningLyrThickness = -0.1;

%shape control
alternativeNum = 1;
sglWpHeight = lyrHeight * pLyrNum;
allWpHeight = sglWpHeight * alternativeNum;
zOffset = 0;
zOffsetRng = [zOffset, allWpHeight + zOffset];
outterWallRange = [1.8, 1];
startIdx = 9;

% alternative
usingRTCP = 0;
    
%%
pg = cPathGen(filename); % create the path generator object
pg.genNewScript();
pg.draw_ = true;
pg.experiment_ = false;

for zOffset = zOffsetRng(1): sglWpHeight: zOffsetRng(2)
    %%%%%%%%%%%%%% printing path 
    pg.addCmd(";;;;;start a printing process");
    tol = 0.1;
    pg.pauseProgramMust();
    [printPathSeq,pwrSeq] = handle.genPrintingPath(cubeLength, startCtr, tol, pLyrNum, lyrHeight, pwr, zOffset, channel, step);
    genPrintingProcess(pg, safetyHeight, printPathSeq, pwrSeq, pFeedrate);

    %%%%%%%%%%%%%% rough machining path
    tol = 0.2;
    %%%%%%%%%%%%%%%%%%%%% plannar machining %%%%%%%%%%%%%%%%%%%%
    pg.addCmd(";;;;;start a planar machining process");
    depthRng = [sglWpHeight+zOffset+planarMachiningDepth, sglWpHeight+zOffset];
    planarPathSeq  = planarMachining([startCtr(1) + 0.5* cubeLength, startCtr(2) + 0.5 * (channel - 1) * step], depthRng, [cubeLength, (channel - 1) * step], machiningLyrThickness, plannarToolRadiu);
    genMachiningProcess(pg, safetyHeight, plannarToolNum, planarPathSeq, planarFeed, 0, side);    
    pg.drawPath(printPathSeq, planarPathSeq);
    
    %%%%%%%%%%%%%%%%%%%%%%%% machining outter wall %%%%%%%%%%%%%%%%%%%%%%%%
    pg.addCmd(";;;;;start an outter wall machining process");
    side = 1;
    allOutterPath = [];
    for wallOffset = outterWallRange(1): machiningLyrThickness : outterWallRange(2)
    %%%%%%%%%%%%%% machining path
        outMachiningPathSeq = handle.genMachiningPath(cubeLength, startCtr, tol, sglWpHeight, lyrHeight, wallToolRadiu, wallOffset, zOffset, side);
        allOutterPath = [allOutterPath; outMachiningPathSeq];
    end
	genMachiningProcess(pg, safetyHeight, wallToolNum, allOutterPath, mFeedrate, usingRTCP, side);
    pg.drawPath(allOutterPath, allOutterPath);    
    pg.alternation_ = pg.alternation_ + 1;
end

pg.closeScript();