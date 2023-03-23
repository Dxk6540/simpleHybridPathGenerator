% this is an example of generate machining process
close all
% file param:
pFilename = strcat('./alternativeTest',date,'.txt');

hProc = cHybridProcess(pFilename);
hProc.sMachinParam_.spindleSpeed = 8000; % mm/min
hProc.sMachinParam_.mFeedrate = 1200; % both powder are used
hProc.sMachinParam_.toolNum = 2;
hProc.sMachinParam_.toolRadiu = 3;
hProc.sPrintParam_.pFeedrate = 600; % mm/min
hProc.sPrintParam_.powderMode = 1; % left powder are used

%  geometry param
startCtr = [60,-45];

radius = 40;




cubeLength = 40;
startPoint = [60, -45]; % left corner
tol = 0.1;
pLyrNum = 30;
lyrHeight = 0.5;
zOffset = 0.5;
channel = 6; 
step = 1; % lap
cubeWidth = channel * step;
wpHeight = pLyrNum * lyrHeight;
machiningLyrThickness = -0.1;

% shape
handle=cube;

% alternative param
planarMachiningDepth = 2;
sglWpHeight = pLyrNum * lyrHeight;
alterNum = 1;
zOffsetRng = [zOffset, zOffset*alterNum];
wallOffsetRng = [1.5, 0.6];

%%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%
%%%% the regular code for generate a script
pg = cPathGen(pFilename); % create the path generator object
pg.genNewScript();
pg.draw_ = true;


for zOffset = zOffsetRng(1): sglWpHeight: zOffsetRng(2)
    %%%%%%% gen printing process %%%%%%
    pg.addCmd(";;;;;start a printing process;;;;;;;;;;");
    [pPathSeq, pwrSeq] = handle.genPrintingPath(cubeLength, startPoint, tol, pLyrNum, lyrHeight, ...
                                        hProc.sPrintParam_.pwr, zOffset, channel, step);
    hProc.genNormalPrintingProcess(pg, pPathSeq, pwrSeq, hProc.sPrintParam_.pFeedrate, hProc.sPrintParam_);
    
    %%%%%%%%%%%%%%%%%%%%% plannar circle machining %%%%%%%%%%%%%%%%%%%%
    pg.addCmd(";;;;;start a planar machining process");
    depthRng = [sglWpHeight+zOffset+planarMachiningDepth, sglWpHeight+zOffset];
    planarPathSeq = planarMachining([startPoint(1)+cubeLength/2,startPoint(2)+cubeWidth/2], depthRng, [cubeLength, cubeWidth], ...
                                        machiningLyrThickness, hProc.sMachinParam_.toolRadiu);
%     genMachiningProcess(pg, safetyHeight, plannarToolNum, planarPathSeq, planarFeedSeq, 0, side);   
    ret = hProc.genNormalMachiningProcess(pg, planarPathSeq, hProc.sMachinParam_.mFeedrate, 1, hProc.sMachinParam_);
    pg.drawPath(pPathSeq, planarPathSeq);    
    
    %%%%%%%%%%%%%%%%%%%%%%%% gen outter machining process %%%%%%%%%%%%%%%%%%%%%%%
    pg.addCmd(";;;;;start a outter machining process");    
    side = 1;
    totalMachiningPath = [];
    for wallOffset = wallOffsetRng(1) : machiningLyrThickness : wallOffsetRng(2)
        mPathSeq = handle.genMachiningPath(cubeLength, cubeWidth, startPoint, tol, wpHeight, ...
                                                lyrHeight, hProc.sMachinParam_.toolRadiu, wallOffset, zOffset, side);
        totalMachiningPath = [totalMachiningPath; mPathSeq];                                  
    end
    ret = hProc.genNormalMachiningProcess(pg, totalMachiningPath, hProc.sMachinParam_.mFeedrate, side, hProc.sMachinParam_);

    %%% draw the path
    pg.drawPath(totalMachiningPath, totalMachiningPath);
end

pg.closeScript();
