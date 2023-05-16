function ret = genNormalPrintingProcess(obj, pg, pPathSeq, pwrSeq, pFeedrate, printParam)
    pwr = printParam.pwr; % 1.2KW / 4kw *1000;
    lenPos = printParam.lenPos;
    flowL = printParam.flowL; % 6 L/min / 20L/min * 1000;
    speedL = printParam.speedL;% 2 r/min / 10r/min * 1000;
    flowR = printParam.flowR;% 6 L/min / 20L/min * 1000;
    speedR = printParam.speedR;% 2 r/min / 10r/min * 1000;
    lenPosSeq = ones(length(pPathSeq),1) * printParam.lenPos;
    
    safetyHeight = obj.sProcessParam_.safetyHeight;
    usingRTCP = obj.sProcessParam_.usingRTCP;
    
    %%% start printing mode
    pg.changeMode(1); % change to printing mode
    pg.setLaser(pwr, lenPos, flowL, speedL, flowR, speedR); % set a init process param (in case of overshoot)
%     pg.saftyToPt([nan, nan, safetyHeight], [startCtr(1) + radius, startCtr(2), 0], 3000); % safety move the start pt

    if usingRTCP == 1
        pg.startRTCP(safetyHeight, 16);        
    end    
    
    pg.saftyToPt([nan, nan, safetyHeight], pPathSeq(1,:), obj.sProcessParam_.travelFeedrate); % safety move the start pt
    if pg.alternation_==1
        pg.pauseProgramMust();
    else
        pg.pauseProgram();% pause and wait for start (the button)
    end
    pg.enableLaser(printParam.powderMode, printParam.laserDelay);
    %%% add path pts
    pg.addPathPtsWithPwr(pPathSeq, pwrSeq, lenPosSeq, pFeedrate);
    %%% exist printing mode
    pg.disableLaser(printParam.powderMode);
    
    if usingRTCP == 1
        pg.stopRTCP(safetyHeight, 16);        
    end    
    pg.returnToSafety(safetyHeight, obj.sProcessParam_.travelFeedrate);
    
    ret = 1;
    
end