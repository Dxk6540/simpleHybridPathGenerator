% this is an example of generating alternative path.
% the script generate a path to printing a cube with contourPath, 
% then machining its top surface and outter surface.
% the above process will totally repeat alterNum + 1 times.
close all
% file param:
pFilename = strcat('./tutorial4_alternativeTest',date,'.txt');

hProc = cHybridProcess(pFilename);
hProc.sMachinParam_.spindleSpeed = 8000; % mm/min
hProc.sMachinParam_.mFeedrate = 2000; % both powder are used
hProc.sMachinParam_.toolNum = 3;
hProc.sMachinParam_.toolRadiu = 5;
hProc.sPrintParam_.pFeedrate = 1100; % mm/min
hProc.sPrintParam_.powderMode = 1; % left powder are used

%  geometry param
cubeLength = [50, 10];
startPoint = [-15, 50]; % left corner
tol = 0.1;
pLyrNum = 30;
lyrHeight = 0.5;
zOffset = 0;
step = 1; % lap
wpHeight = pLyrNum * lyrHeight;
machiningLyrThickness = -0.1;

% shape
handle = contourPathCube;

% alternative param
planarMachiningDepth = 3;
sglWpHeight = pLyrNum * lyrHeight;
alterNum = 1;
zOffsetRng = [zOffset, zOffset + sglWpHeight*alterNum]; 
wallOffsetRng = [0.8, 0];

%%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%
%%%% the regular code for generate a script
pg = cPathGen(pFilename); % create the path generator object
pg.genNewScript();
pg.draw_ = true;


for zOffset = zOffsetRng(1): sglWpHeight: zOffsetRng(2)
    %%%%%%% gen printing process %%%%%%
    pg.addCmd(";;;;;start a printing process;;;;;;;;;;");
    [pPathSeq, pwrSeq, feedOffset] = handle.genPrintingPath(cubeLength, startPoint, tol, pLyrNum, lyrHeight, ...
                                        hProc.sPrintParam_.pwr, zOffset, channel, step);
    hProc.genNormalPrintingProcess(pg, pPathSeq, pwrSeq, hProc.sPrintParam_.pFeedrate * feedOffset, hProc.sPrintParam_);
    
    %%%%%%%%%%%%%%%%%%%%% plannar circle machining %%%%%%%%%%%%%%%%%%%%
    pg.addCmd(";;;;;start a planar machining process");
    depthRng = [sglWpHeight+zOffset+planarMachiningDepth, sglWpHeight+zOffset];
    planarPathSeq = planarMachining([startPoint(1) - hProc.sMachinParam_.toolRadiu  + cubeLength(1)/2, startPoint(2) + cubeLength(2)/2], depthRng, cubeLength, ...
                                        machiningLyrThickness, hProc.sMachinParam_.toolRadiu);
%     genMachiningProcess(pg, safetyHeight, plannarToolNum, planarPathSeq, planarFeedSeq, 0, side);   
    ret = hProc.genNormalMachiningProcess(pg, planarPathSeq, hProc.sMachinParam_.mFeedrate, 1, hProc.sMachinParam_);
    pg.drawPath(pPathSeq, planarPathSeq);    
    
    %%%%%%%%%%%%%%%%%%%%%%%% gen outter machining process %%%%%%%%%%%%%%%%%%%%%%%
    pg.addCmd(";;;;;start a outter machining process");    
    side = 1;
    totalMachiningPath = [];
    for wallOffset = wallOffsetRng(1) : machiningLyrThickness : wallOffsetRng(2)
        mPathSeq = handle.genMachiningPath(cubeLength(1), cubeLength(2), startPoint, tol, wpHeight, ...
                                                lyrHeight, hProc.sMachinParam_.toolRadiu, wallOffset, zOffset, side);
        totalMachiningPath = [totalMachiningPath; mPathSeq];                                  
    end
    ret = hProc.genNormalMachiningProcess(pg, totalMachiningPath, hProc.sMachinParam_.mFeedrate, side, hProc.sMachinParam_);

    %%% draw the path
    pg.drawPath(totalMachiningPath, totalMachiningPath);
end

pg.closeScript();
