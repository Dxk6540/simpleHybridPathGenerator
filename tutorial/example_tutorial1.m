% this is an example of using cPathGen class and cHybridProcess class.
addpath('../lib')

% file param:
pFilename = strcat('./tutorial_1_printingTest',date,'.txt');

hProc = cHybridProcess(pFilename);
hProc.sPrintParam_.pFeedrate = 600; % mm/min
hProc.sPrintParam_.powderMode = 1; % both powder are used


%  geometry param
startCtr = [-60,-50];
% inclinationAgl = 0; % degree
pLyrNum = 20;
lyrHeight = 0.5;
radius = 20;
tol = 0.1;
zOffset = 0;
channel = 2;
step = 1;

% shape
handle=cylinder;

%%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%
%%%% the regular code for generate a script
pg = cPathGen(pFilename); % create the path generator object
pg.genNewScript();
[pPathSeq,pwrSeq, feedSeq] = handle.genPrintingPath(radius, startCtr, tol, pLyrNum, ...
                                                lyrHeight, hProc.sPrintParam_.pwr, zOffset, channel, step);
                                            
hProc.genNormalPrintingProcess(pg, pPathSeq, pwrSeq, feedSeq*hProc.sPrintParam_.pFeedrate, hProc.sPrintParam_);    
pg.closeScript();

%%% draw the path
pg.drawPath(pPathSeq, pPathSeq);