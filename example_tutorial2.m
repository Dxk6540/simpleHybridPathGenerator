% this is an example of generate gradient material using genGradMtrlPrintingProcess.
% the process is an alternative printing process with different material
% mixing.

% file param:
pFilename = strcat('./tutorial2_gradientMaterialTest',date,'.txt');

hProc = cHybridProcess(pFilename);
hProc.sPrintParam_.pFeedrate = 600; % mm/min
hProc.sPrintParam_.powderMode = 3; % both powder are used
hProc.sPrintParam_.pwr = 150;

%  geometry param
startCtr = [60,-45];
pLyrNum = 20;
lyrHeight = 0.3;
radius = 20;
tol = 0.3;
zOffset = 0;
channel = 6;
step = 1;

% shape control
handle=cylinder;
sglHeight = pLyrNum * lyrHeight;

%%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%
%%%% the regular code for generate a script
pg = cPathGen(pFilename); % create the path generator object
pg.genNewScript();
pg.draw_ = true;

procCell = cell(3,4);
% generate a process with the first material 
procIdx = 1;
zOffset = zOffset + 0;
[pPathSeq, pwrSeq, feedSeq] = handle.genPrintingPath(radius, startCtr, tol, pLyrNum, ...
                                                lyrHeight, hProc.sPrintParam_.pwr, zOffset, channel, step);
procCell{procIdx,1} = pPathSeq;
procCell{procIdx,2} = pwrSeq;
procCell{procIdx,3} = feedSeq;
procCell{procIdx,4} = [250, 100, 250, 0]; % [flowL, speedL, flowR, speedR].
pg.drawPath(pPathSeq, pPathSeq);

% generate the second process with the second material 
procIdx = 2;
zOffset = zOffset + sglHeight;
[pPathSeq, pwrSeq] = handle.genPrintingPath(radius, startCtr, tol, pLyrNum, ...
                                                lyrHeight, hProc.sPrintParam_.pwr, zOffset, channel, step);
procCell{procIdx,1} = pPathSeq;
procCell{procIdx,2} = pwrSeq;
procCell{procIdx,3} = feedSeq;
procCell{procIdx,4} = [250, 0, 250, 100]; % [flowL, speedL, flowR, speedR].
pg.drawPath(pPathSeq, pPathSeq);

% generate the third process with both the two materials 
procIdx = 3;
zOffset = zOffset + sglHeight;
[pPathSeq, pwrSeq, feedSeq] = handle.genPrintingPath(radius, startCtr, tol, pLyrNum, ...
                                                lyrHeight, hProc.sPrintParam_.pwr, zOffset, channel, step);
procCell{procIdx,1} = pPathSeq;
procCell{procIdx,2} = pwrSeq;
procCell{procIdx,3} = feedSeq;
procCell{procIdx,4} = [250, 50, 250, 50]; % [flowL, speedL, flowR, speedR].
pg.drawPath(pPathSeq, pPathSeq);

hProc.genGradMtrlPrintingProcess(pg, procCell, hProc.sPrintParam_);    
pg.closeScript();

%%% draw the path


