function ret = genMachiningProcess(pg, safetyHeight, toolNum, mPathSeq, mFeedrate)
    spindleSpeed = 10000;
    safetyPt = mPathSeq(1,:);
    safetyPt(3) = safetyPt(3) + 5; % z offset 5 mm
    
    %%% start machining mode
    pg.changeMode(2); % change to machining mode
    pg.changeTool(toolNum);
%     pg.saftyToPt([nan, nan, safetyHeight], [startCtr(1) + side*(radius + toolRadiu + wallOffset + 5), startCtr(2), pLyrNum * lyrHeight], 3000); % safety move the start pt
    pg.saftyToPt([nan, nan, safetyHeight], safetyPt, 3000); % safety move the start pt
    pg.pauseProgram();% pause and wait for start (the button)
    pg.enableSpindle(spindleSpeed, toolNum); % set a init process param (in case of overshoot)
    %%% add path pts
    pg.addPathPts(mPathSeq, mFeedrate);
    %%% exist machining mode
    pg.disableSpindle();
    pg.returnToSafety(safetyHeight, 3000);
    ret = 1;
end