% this is an example of generating alternative path.
% the script generate a path to printing a cube with contourPath, 
% then machining its top surface and outter surface.
% the above process will totally repeat alterNum + 1 times.
addpath('../lib')
addpath('../lib/shape')

close all
% file param:
pFilename = strcat('./planarMachining',date,'.txt');

hProc = cHybridProcess(pFilename);
hProc.sMachinParam_.spindleSpeed = 6000; % mm/min
hProc.sMachinParam_.mFeedrate = 1000; % both powder are used
hProc.sMachinParam_.toolNum = 5;
hProc.sMachinParam_.toolRadiu = 5;


startPoint = [20, -7.5]; % left corner
% startPoint = startPoint-[3,3]; % left corner
cubeLength = [20, 15]; % cube shape
% cubeLength = cubeLength+[6,6];
machiningLyrThickness = -0.2;% cutting depth
planarMachiningDepth = 3; % total depth
zOffset = 0;
pLyrNum = 20;
lyrHeight = 0.5;


%  geometry param
tol = 0.1;
wpHeight = pLyrNum * lyrHeight;

% shape
handle = contourPathCube;
sglWpHeight = pLyrNum * lyrHeight;

%%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%
%%%% the regular code for generate a script
pg = cPathGen(pFilename); % create the path generator object
pg.genNewScript();
pg.draw_ = true;

%%%%%%%%%%%%%%%%%%%%% plannar circle machining %%%%%%%%%%%%%%%%%%%%
pg.addCmd(";;;;;start a planar machining process");
depthRng = [sglWpHeight+zOffset+planarMachiningDepth, sglWpHeight+zOffset];
planarPathSeq = planarMachining([startPoint(1) - hProc.sMachinParam_.toolRadiu  + cubeLength(1)/2, startPoint(2) + cubeLength(2)/2], depthRng, cubeLength, ...
                                    machiningLyrThickness, hProc.sMachinParam_.toolRadiu);
ret = hProc.genNormalMachiningProcess(pg, planarPathSeq, hProc.sMachinParam_.mFeedrate, 1, hProc.sMachinParam_);
pg.drawPath(planarPathSeq, planarPathSeq);    
    

pg.closeScript();
