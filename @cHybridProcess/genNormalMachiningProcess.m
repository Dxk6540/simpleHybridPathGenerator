function ret = genNormalMachiningProcess(obj, pg, mPathSeq, mFeedrate, side, machiningParam)
    safetyHeight = obj.sProcessParam_.safetyHeight;
    usingRTCP = obj.sProcessParam_.usingRTCP;
    
    spindleSpeed = machiningParam.spindleSpeed;
    toolNum = machiningParam.toolNum;
    
    safetyPt = mPathSeq(1,:);
    safetyPt(1) = safetyPt(1) - 1 * 2; % x offset 5 mm
    safetyPt(3) = safetyPt(3) + 5; % z offset 5 mm
    
    %%% start machining mode
    pg.changeMode(2); % change to machining mode
    pg.changeTool(toolNum);
%     pg.saftyToPt([nan, nan, safetyHeight], [startCtr(1) + side*(radius + toolRadiu + wallOffset + 5), startCtr(2), pLyrNum * lyrHeight], 3000); % safety move the start pt
    if usingRTCP == 1
        pg.startRTCP(safetyHeight, toolNum);        
    end    
    pg.saftyToPt([nan, nan, safetyHeight], safetyPt, 3000); % safety move the start pt
    pg.pauseProgram();% pause and wait for start (the button)
    pg.enableSpindle(spindleSpeed, toolNum); % set a init process param (in case of overshoot)
    %%% add path pts
    pg.addPathPts(mPathSeq, mFeedrate);
    %%% exist machining mode
    pg.disableSpindle();
    if usingRTCP == 1
        pg.stopRTCP(safetyHeight, toolNum);        
    end
    pg.returnToSafety(safetyHeight, obj.sProcessParam_.travelFeedrate);        

    ret = 1;
end