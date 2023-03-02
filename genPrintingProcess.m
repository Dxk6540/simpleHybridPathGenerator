function ret = genPrintingProcess(pg, safetyHeight, pPathSeq, pwrSeq, pFeedrate)
    pwr = 300; % 1.2KW / 4kw *1000;
    lenPos = 900;
    flowL = 250; % 6 L/min / 20L/min * 1000;
    speedL = 100;% 2 r/min / 10r/min * 1000;
    flowR = 250;% 6 L/min / 20L/min * 1000;
    speedR = 100;% 2 r/min / 10r/min * 1000;
    lenPosSeq = ones(length(pPathSeq),1) * lenPos;

    %%% start printing mode
    pg.changeMode(1); % change to printing mode
    pg.setLaser(pwr, lenPos, flowL, speedL, flowR, speedR); % set a init process param (in case of overshoot)
%     pg.saftyToPt([nan, nan, safetyHeight], [startCtr(1) + radius, startCtr(2), 0], 3000); % safety move the start pt
    pg.saftyToPt([nan, nan, safetyHeight], pPathSeq(1,:), 3000); % safety move the start pt
    if pg.alternation_==1
        pg.pauseProgramMust();
    else
        pg.pauseProgram();% pause and wait for start (the button)
    end
    pg.enableLaser(1, 10);
    %%% add path pts
    pg.addPathPtsWithPwr(pPathSeq, pwrSeq, lenPosSeq, pFeedrate);
    %%% exist printing mode
    pg.disableLaser(1);
    pg.returnToSafety(safetyHeight, 3000);
    
    ret = 1;
    
end



