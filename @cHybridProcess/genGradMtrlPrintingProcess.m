function ret = genGradMtrlPrintingProcess(obj, pg, processCell, printParam)
% processCell: N*4 cell matrix. in which:
% (i,1) is pPathSeq, (i,2) is pwrSeq,  (i,3) is pFeedrate, (i,4) is materialParam. 
% materialParam is 4d [flowL, speedL, flowR, speedR].
        
    [procNum, ~] = size(processCell);
    pwr = printParam.pwr; % 1.2KW / 4kw *1000;
    lenPos = printParam.lenPos;
    flowL = printParam.flowL; % 6 L/min / 20L/min * 1000;
    speedL = printParam.speedL;% 2 r/min / 10r/min * 1000;
    flowR = printParam.flowR;% 6 L/min / 20L/min * 1000;
    speedR = printParam.speedR;% 2 r/min / 10r/min * 1000;
    
    safetyHeight = obj.sProcessParam_.safetyHeight;
    pPathSeq = processCell{1, 1};

    pg.changeMode(1); % change to printing mode
    pg.setLaser(pwr, lenPos, flowL, speedL, flowR, speedR); % set a init process param (in case of overshoot)
%     pg.saftyToPt([nan, nan, safetyHeight], [startCtr(1) + radius, startCtr(2), 0], 3000); % safety move the start pt
    pg.saftyToPt([nan, nan, safetyHeight], pPathSeq(1,:), obj.sProcessParam_.travelFeedrate); % safety move the start pt
    if pg.alternation_==1
        pg.pauseProgramMust();
    else
        pg.pauseProgram();% pause and wait for start (the button)
    end
    pg.enableLaser(printParam.powderMode, printParam.laserDelay);

    %%% add path pts
    for procIdx = 1 : procNum
        pPathSeq = processCell{procIdx, 1};
        [seqSize, ~] = size(pPathSeq);
        pwrSeq = processCell{procIdx, 2};
        if size(pwrSeq) == 1
            pwrSeq = ones(seqSize,1)* pwrSeq;
        end
        lenPosSeq = ones(seqSize,1)* lenPos;      
        pFeedrate = processCell{procIdx, 3};
        
        % set material param
        mtrlParam = processCell{procIdx, 4};
        pg.changePowder(mtrlParam(1), mtrlParam(2), mtrlParam(3), mtrlParam(4), 10); % delay 10s for change powder
        pg.setLaser(pwrSeq(1), lenPosSeq(1), mtrlParam(1), mtrlParam(2), mtrlParam(3), mtrlParam(4)); 
        % set the path
        pg.addPathPtsWithPwr(pPathSeq, pwrSeq, lenPosSeq, pFeedrate);        
    end
    %%% exist printing mode
    pg.disableLaser(printParam.powderMode);
    pg.returnToSafety(safetyHeight, obj.sProcessParam_.travelFeedrate);
    
    ret = 1;    
end