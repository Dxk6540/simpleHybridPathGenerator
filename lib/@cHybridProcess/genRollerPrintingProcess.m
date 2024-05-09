% function ret = genRollerPrintingProcess(obj, pg, pPathSeq, pwrSeq, pFeedrate, printParam)
function ret = genRollerPrintingProcess(obj, pg, processCell, interPt, printParam)

    [procNum, ~] = size(processCell);
    pwr = printParam.pwr; % 1.2KW / 4kw *1000;
    lenPos = printParam.lenPos;
    flowL = printParam.flowL; % 6 L/min / 20L/min * 1000;
    speedL = printParam.speedL;% 2 r/min / 10r/min * 1000;
    flowR = printParam.flowR;% 6 L/min / 20L/min * 1000;
    speedR = printParam.speedR;% 2 r/min / 10r/min * 1000;
%     lenPosSeq = ones(length(pPathSeq),1) * printParam.lenPos;
    
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

%     pg.enableLaser(printParam.powderMode, printParam.laserDelay);
%     %%% add path pts
%     pg.addPathPtsWithPwr(pPathSeq, pwrSeq, lenPosSeq, pFeedrate);
%     %%% exist printing mode
%     pg.disableLaser(printParam.powderMode);

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
        pg.enableLaser(printParam.powderMode, printParam.laserDelay);        
        pg.changePowder(mtrlParam(1), mtrlParam(2), mtrlParam(3), mtrlParam(4), printParam.laserDelay); % delay 10s for change powder
        pg.setLaser(pwrSeq(1), lenPosSeq(1), mtrlParam(1), mtrlParam(2), mtrlParam(3), mtrlParam(4)); 
        % set the path
        pg.addPathPtsWithPwr(pPathSeq, pwrSeq, lenPosSeq, pFeedrate); 
        pg.disableLaser(printParam.powderMode);
    end

    if usingRTCP == 1
        pg.stopRTCP(safetyHeight, 16);        
    end    
    pg.returnToSafety(safetyHeight, obj.sProcessParam_.travelFeedrate);
    
    ret = 1;
    
end