addpath(genpath('../lib'));
% file param:
pFilename = strcat('./cylinder',date,'.txt');

%% Printing shape sequence
shapeHandle = cylinder();
% geometry parameters
startCenter = [60,0];% X/Y of the center point
% inclinationAgl = 0; % degree
lyrNum = 60; % The printing layer number
lyrThickness = 0.6;% The height of each layer. This is determined by the laser feedrate and powder amount
cylinderR = 20;% The radius of the middle countour circle of the tube
tol = 0.1;% Sampling precision, Unit: mm，pick a point every 0.1mm
zOffset = 2;% Z of the center point
channel = 2;% The number of the printing route, total width= 2.4mm+0.8*(channel-1)mm
step = 0.8;% The width of a single priting line 
pwr= 250;% 1KW / 4kw *1000;
[pPathSeq,pwrSeq,feedrateOffset] = shapeHandle.genPrintingPath(cylinderR, startCenter, tol, lyrNum, lyrThickness, pwr, zOffset, channel, step);
[pPathSeq,pwrSeq,feedrateOffset] = AdjustStartPos(pPathSeq,pwrSeq,feedrateOffset);

%% machining path
%%% the regular code for generate a script
pg = cPathGen(pFilename); % create the path generator object
pg.genNewScript();
pg.draw_ = true;

%%% Generate printing path
hProc = cHybridProcess(pFilename);
% Laser
hProc.sPrintParam_.pwr = 250; % 1KW / 4kw *1000; Set a init process param (in case of overshoot), not the power during printing
hProc.sPrintParam_.pFeedrate = 600; % mm/min
hProc.sPrintParam_.lenPos = 900; % ????
% Powder
hProc.sPrintParam_.flowL = 250; % 6 L/min / 20L/min * 1000; ????
hProc.sPrintParam_.speedL = 100; % 2 r/min / 10r/min * 1000; ????
hProc.sPrintParam_.flowR = 0; % 6 L/min / 20L/min * 1000; ????
hProc.sPrintParam_.speedR = 0; % 2 r/min / 10r/min * 1000; ????
hProc.sPrintParam_.powderMode = 1; % 1 - only left is used, 2 - only right is used 3 - both powder are used (for mixing)
hProc.sPrintParam_.laserDelay = 10; % Unit：s, wait XXs and then start the laser
% Process
hProc.sProcessParam_.safetyHeight = 220; % Unit: mm
hProc.sProcessParam_.usingRTCP = 0; % Mode: 0-close, 1-open
hProc.sProcessParam_.travelFeedrate = 3000; % Move speed while not working

% We just want to print one material, the normal printing process is enough.
% (here, one material means the single mixing ratio)
GenNormalPrintingProcess_Detect(hProc, pg, pPathSeq, pwrSeq, hProc.sPrintParam_.pFeedrate, hProc.sPrintParam_);
pg.closeScript();
pg.drawPath(pPathSeq, pPathSeq);