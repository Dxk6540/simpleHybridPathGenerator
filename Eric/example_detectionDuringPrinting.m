% this is an example of using cPathGen class and cHybridProcess class.
% Eric Add some pauses during printing, for the structured light detection

% file param:
pFilename = strcat('DetectionDuringPrinting',date,'.txt');

hProc = cHybridProcess(pFilename);
hProc.sPrintParam_.pFeedrate = 600; % mm/min
hProc.sPrintParam_.powderMode = 1; % only left is used


%  geometry param
startCtr = [-60,0];
% inclinationAgl = 0; % degree
pLyrNum = 60; % The printing layer number
lyrHeight = 0.5;
radius = 20;
tol = 0.1;
zOffset = 0;
channel = 2;
step = 1;

% shape
handle=E_cylinder;



%%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%
%%%% the regular code for generate a script
pg = cPathGen(pFilename); % create the path generator object
pg.genNewScript();
[pPathSeq,pwrSeq, feedSeq] = handle.genPrintingPath(radius, startCtr, tol, pLyrNum, ...
                                                lyrHeight, hProc.sPrintParam_.pwr, zOffset, channel, step);
                                            
new_pPathSeq=AdjustStartPos(pPathSeq);
hProc.genCamMtPrintingProcess(pg, new_pPathSeq, pwrSeq, feedSeq*hProc.sPrintParam_.pFeedrate, hProc.sPrintParam_,pPathSeq);    
pg.closeScript();

%%% draw the path
pg.drawPath(pPathSeq, pPathSeq);