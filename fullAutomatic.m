% file param:
filename = strcat('./fullAutoCylinderTest',date,'.txt');

% printing process param
pwr = 300; % 1.2KW / 4kw *1000;
lenPos = 900;
flowL = 250; % 6 L/min / 20L/min * 1000;
speedL = 100;% 2 r/min / 10r/min * 1000;
flowR = 250;% 6 L/min / 20L/min * 1000;
speedR = 100;% 2 r/min / 10r/min * 1000;
pFeedrate = 600; % mm/min
channel = 2;
step = 1;

% machining process param
mFeedrate = 800; % mm/min
spindleSpeed = 10000;
toolNum = 1;
toolRadiu = 4;
wallOffset = 1.1;
side = 1; % machining inside is -1 and outside is 1

%  geometry param
startCtr = [0,0];
% inclinationAgl = 0; % degree
pLyrNum = 20;
% wpH = 10;
lyrHeight = 0.5;
radius = 20;
tol = 0.1;
safetyHeight = 230;
zOffset = 0;

% shape
handle=cylinder;


%%
pg = cPathGen(filename); % create the path generator object
pg.genNewScript();

% %%%%%%%%%%%%%% printing path
% [pPathSeq,pwrSeq] = handle.genPrintingPath(radius, startCtr, tol, pLyrNum, lyrHeight, pwr, zOffset, channel, step);
% genPrintingProcess(pg, safetyHeight, pPathSeq, pwrSeq, pFeedrate);
% 
% %%%%%%%%%%%%%% machining path
% mPathSeq = handle.genMachiningPath(radius, startCtr, tol, pLyrNum * lyrHeight, lyrHeight, toolRadiu, wallOffset, zOffset, side);
% genMachiningProcess(pg, safetyHeight, toolNum, mPathSeq, mFeedrate);
% 





% alternativeCylinderProcess([3,1], [3,1], 0);

outterWallRange = [3,1];
innerWallRange = [3,1];
zOffset = 0;



lyrThickness = -0.1;
%%%%%%%%%%%%%% printing path
[printPathSeq,pwrSeq] = handle.genPrintingPath(radius, startCtr, tol, pLyrNum, lyrHeight, pwr, zOffset, channel, step);
genPrintingProcess(pg, safetyHeight, printPathSeq, pwrSeq, pFeedrate);

% planar machining
planarPathSeq = planarMachining(pg, startCtr, [pLyrNum * lyrHeight+zOffset+5, pLyrNum * lyrHeight+zOffset], radius*1.5, safetyHeight, toolRadiu, toolNum, mFeedrate);
pg.drawPath(printPathSeq, planarPathSeq);
pause

% machining outter wall
side = 1;
for wallOffset = outterWallRange(1): lyrThickness : outterWallRange(2)
%%%%%%%%%%%%%% machining path
    outMachiningPathSeq = handle.genMachiningPath(radius, startCtr, tol, pLyrNum * lyrHeight, lyrHeight, toolRadiu, wallOffset, zOffset, side);
    genMachiningProcess(pg, safetyHeight, toolNum, outMachiningPathSeq, mFeedrate);
end

% machining inner wall
side = -1;
for wallOffset = innerWallRange(1): lyrThickness : innerWallRange(2)
%%%%%%%%%%%%%% machining path
    inMachiningPathSeq = handle.genMachiningPath(radius, startCtr, tol, pLyrNum * lyrHeight, lyrHeight, toolRadiu, wallOffset, zOffset, side);
    genMachiningProcess(pg, safetyHeight, toolNum, inMachiningPathSeq, mFeedrate);
end
pg.drawPath(outMachiningPathSeq, inMachiningPathSeq);
pause




pg.closeScript();


%% 
%%% draw the path
% pg.drawPath(pPathSeq, mPathSeq);



% function ret = alternativeCylinderProcess(outterWallRange, innerWallRange, zOffset)
% 
% lyrThickness = -0.1;
% %%%%%%%%%%%%%% printing path
% [pPathSeq,pwrSeq] = handle.genPrintingPath(radius, startCtr, tol, pLyrNum, lyrHeight, pwr, zOffset, channel, step);
% genPrintingProcess(pg, safetyHeight, pPathSeq, pwrSeq, pFeedrate);
% 
% 
% % planar machining
% planarMachining(startCtr, [pLyrNum * lyrHeight+zOffset+5, pLyrNum * lyrHeight+zOffset], radius*1.5);
% 
% % machining outter wall
% side = 1;
% for wallOffset = outterWallRange(1): lyrThickness : outterWallRange(2)
% %%%%%%%%%%%%%% machining path
%     mPathSeq = handle.genMachiningPath(radius, startCtr, tol, pLyrNum * lyrHeight, lyrHeight, toolRadiu, wallOffset, zOffset, side);
%     genMachiningProcess(pg, safetyHeight, toolNum, mPathSeq, mFeedrate);
% end
% 
% % machining inner wall
% side = -1;
% for wallOffset = innerWallRange(1): lyrThickness : innerWallRange(2)
% %%%%%%%%%%%%%% machining path
%     mPathSeq = handle.genMachiningPath(radius, startCtr, tol, pLyrNum * lyrHeight, lyrHeight, toolRadiu, wallOffset, zOffset, side);
%     genMachiningProcess(pg, safetyHeight, toolNum, mPathSeq, mFeedrate);
% end
% 
% end



function ret = planarMachining(pg, cntr, depthRange, side, safetyHeight, toolRadiu, toolNum, mFeedrate)
    lyrThickness = -0.1;
    
    passStepOver = toolRadiu/2;    
    if floor(side/passStepOver) == side/passStepOver
        passNum = floor(side/passStepOver);            
    else
        passNum = floor(side/passStepOver) + 1;    
    end
    passStepOver = side / passNum;
    
    xRange = [cntr(1) - side/2, cntr(1) + side/2];
    yRange = [cntr(2) - side/2, cntr(2) + side/2];
    planarPathSeq = [];    
    for zPos = depthRange(1): lyrThickness: depthRange(2)
        for yPos = yRange(1): passStepOver: yRange(2)
            planarPathSeq = [planarPathSeq; 
                             xRange(1), yPos, zPos;
                             xRange(2), yPos, zPos;
                             xRange(1), yPos, zPos];            
        end
    end

    genMachiningProcess(pg, safetyHeight, toolNum, planarPathSeq, mFeedrate);    
%     pg.drawPath(planarPathSeq, planarPathSeq);
%     pause
    ret = planarPathSeq;
end






