% this is an example of using cPathGen class and cHybridProcess class.
addpath('../lib')
addpath('../lib/shape')

% file param:
pFilename = strcat('./tutorial1_printing',date,'.txt');

hProc = cHybridProcess(pFilename);
hProc.sPrintParam_.pFeedrate = 600; % mm/min
hProc.sPrintParam_.powderMode = 1; % left powder are used


%  geometry param
startCtr = [0,0];% left-bottom corner point
cubeShape= [40,30];% length and width
% inclinationAgl = 0; % degree
pLyrNum = 50;
lyrHeight = 0.5;
tol = 0.1;% 
zOffset = 0;% 

step = 1;% 

% shape
handle=zigzagPathCube;

%%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%
%%%% the regular code for generate a script
pg = cPathGen(pFilename); % create the path generator object
pg.genNewScript();
[pPathSeq,pwrSeq, feedSeq] = handle.genPrintingPath(cubeShape, startCtr, tol, pLyrNum, ...
                                                lyrHeight, hProc.sPrintParam_.pwr, zOffset, channel, step);
                                            
hProc.genNormalPrintingProcess(pg, pPathSeq, pwrSeq, feedSeq*hProc.sPrintParam_.pFeedrate, hProc.sPrintParam_);    
pg.closeScript();

%%% draw the path
pg.drawPath(pPathSeq, pPathSeq);