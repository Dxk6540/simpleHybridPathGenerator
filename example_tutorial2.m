% this is an example of generate gradient material using genGradMtrlPrintingProcess.

% file param:
pFilename = strcat('./gradientMaterialTest',date,'.txt');

hProc = cHybridProcess(pFilename);
hProc.sPrintParam_.pFeedrate = 600; % mm/min
hProc.sPrintParam_.powderMode = 3; % both powder are used


%  geometry param
startCtr = [0,0];
pLyrNum = 5;
lyrHeight = 0.5;
radius = 20;
tol = 3;
zOffset = 0;
channel = 2;
step = 1;

% shape
handle=cylinder;



%%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%
%%%% the regular code for generate a script
pg = cPathGen(pFilename); % create the path generator object
pg.genNewScript();

procCell = cell(3,4);

% generate a process with the first material 
procIdx = 1;
[pPathSeq, pwrSeq, feedSeq] = handle.genPrintingPath(radius, startCtr, tol, pLyrNum, ...
                                                lyrHeight, hProc.sPrintParam_.pwr, zOffset, channel, step);
procCell{procIdx,1} = pPathSeq;
procCell{procIdx,2} = pwrSeq;
procCell{procIdx,3} = feedSeq;
procCell{procIdx,4} = [250, 100, 250, 0]; % [flowL, speedL, flowR, speedR].

% generate the second process with the second material 
procIdx = 2;
[pPathSeq, pwrSeq, feedSeq] = handle.genPrintingPath(radius, startCtr, tol, pLyrNum, ...
                                                lyrHeight, hProc.sPrintParam_.pwr, zOffset, channel, step);
procCell{procIdx,1} = pPathSeq;
procCell{procIdx,2} = pwrSeq;
procCell{procIdx,3} = feedSeq;
procCell{procIdx,4} = [250, 0, 250, 100]; % [flowL, speedL, flowR, speedR].

% generate the third process with both the two materials 
procIdx = 3;
[pPathSeq, pwrSeq, feedSeq] = handle.genPrintingPath(radius, startCtr, tol, pLyrNum, ...
                                                lyrHeight, hProc.sPrintParam_.pwr, zOffset, channel, step);
procCell{procIdx,1} = pPathSeq;
procCell{procIdx,2} = pwrSeq;
procCell{procIdx,3} = feedSeq;
procCell{procIdx,4} = [250, 50, 250, 50]; % [flowL, speedL, flowR, speedR].

hProc.genGradMtrlPrintingProcess(pg, procCell, hProc.sPrintParam_);    
pg.closeScript();

%%% draw the path
pg.drawPath(pPathSeq, pPathSeq);


