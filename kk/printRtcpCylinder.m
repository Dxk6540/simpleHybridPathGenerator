% this is an example of generate a single layer machining process
addpath('../lib')
addpath('../lib/shape')

% file param:
pFilename = strcat('./tutorial3_machiningTest',date,'.txt');

hProc = cHybridProcess(pFilename);
hProc.sMachinParam_.spindleSpeed = 8000; % mm/min
hProc.sMachinParam_.mFeedrate = 1000; % both powder are used
hProc.sMachinParam_.toolNum = 2;
hProc.sMachinParam_.toolRadiu = 3;

%  geometry param
startCtr = [60,-45];
pLyrNum = 30;
lyrHeight = 0.3;
radius = 40;
tol = 0.1;
zOffset = 0.5;
channel = 6;
step = 1;

% % shape
% handle=contourPathCube;
% 
% 
% 
% %%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%
% %%%% the regular code for generate a script
% pg = cPathGen(pFilename); % create the path generator object
% pg.genNewScript();
% pg.draw_ = true;
% 
% % path = genMachiningPath(cubeLength, startPoint, tol, wpHeight, lyrThickness, toolRadiu, wallOffset, zOffset,side)
% wallOffset = 0.6;
% side = 1;
% mPathSeq = handle.genMachiningPath(radius, 5, startCtr, tol, pLyrNum * lyrHeight, ...
%                                                 lyrHeight, hProc.sMachinParam_.toolRadiu, wallOffset, zOffset, side);
% 
% % hProc.genNormalPrintingProcess(pg, pPathSeq, pwrSeq, hProc.sPrintParam_.pFeedrate, hProc.sPrintParam_);
% ret = hProc.genNormalMachiningProcess(pg, mPathSeq, hProc.sMachinParam_.mFeedrate, side, hProc.sMachinParam_);
% pg.closeScript();
% 
% %%% draw the path
% pg.drawPath(mPathSeq, mPathSeq);

























%%%%%%%%%%%%%%%%%%%
%
% with RTCP function.
% date: 2023-3-3
%
%%%%%%%%%%%%%%%%%%

% file param:
pFilename = strcat('./vaseTest',date,'.txt');
mFilename = strcat('./vaseTestMachinig',date,'.txt');


hProc = cHybridProcess(pFilename);
hProc.sMachinParam_.spindleSpeed = 8000; % mm/min
hProc.sMachinParam_.mFeedrate = 1000; % both powder are used
hProc.sMachinParam_.toolNum = 2;
hProc.sMachinParam_.toolRadiu = 3;


%  geometry param
cylinderGeo = cRtcpCylinder.getDefaultParam();
cylinderGeo.profileRadiu = 10;
cylinderGeo.height = 20;
cylinderGeo.center = [50,20,10];
cylinderGeo.tol = 0.1;
cylinderGeo.lyrThickness = 0.5; % max rad?

safetyHeight = 230;
side = 1; % machining inside is -1 and outside is 1
wallOffset = 0;
rollAgl = pi/6; %the rot angle is the angle between the tool axis and tangent
% mPathSeq = cRtcpCylinder.genMachiningPath(radius, startCtr, tol, wpHeight, lyrThichness, toolRadiu, wallOffset, zOffset, side, 0);
mPathSeq = cRtcpCylinder.genMachiningPath(0, cylinderGeo, hProc, wallOffset, side, 0);

%%%%%%%%%%%%% following for RTCP path Gen %%%%%%%%%%%%%%%%%%%%%
%%%% the regular code for generate a script
pg = cPathGen(mFilename); % create the path generator object
pg.genNewScript();
%%% start machining mode
pg.changeMode(2); % change to machining mode
pg.changeTool(toolNum);
pg.startRTCP(safetyHeight, toolNum);
pg.saftyToPt([nan, nan, safetyHeight], [startCtr(1) + side*(radius + toolRadiu + wallOffset + 5), startCtr(2), pLyrNum * lyrHeight], 3000); % safety move the start pt
pg.pauseProgram();% pause and wait for start (the button)
pg.enableSpindle(spindleSpeed, toolNum); % set a init process param (in case of overshoot)
%%% add path pts
pg.addPathPts(mPathSeq, mFeedrate);
%%% exist machining mode
pg.disableSpindle();
pg.stopRTCP(safetyHeight, toolNum);
pg.returnToSafety(safetyHeight, 3000);
%%% end the script
pg.closeScript();



%%% draw the path
pg.drawPath(mPathSeq, mPathSeq);




