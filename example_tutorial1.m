% this is an example of using cPathGen class and cHybridProcess class.

% file param:
pFilename = strcat('./usTemperatureTest',date,'.txt');

hProc = cHybridProcess(pFilename);
hProc.sPrintParam_.pFeedrate = 600; % mm/min
hProc.sPrintParam_.powderMode = 3; % both powder are used


%  geometry param
startCtr = [0,0];
% inclinationAgl = 0; % degree
pLyrNum = 10;
lyrHeight = 0.5;
radius = 20;
tol = 0.1;
zOffset = 30;
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


