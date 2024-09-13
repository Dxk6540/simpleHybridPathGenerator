function ret = GenNormalPrintingProcess_Detect(obj, pg, pPathSeq, pwrSeq, pFeedrate, printParam)
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

    %% Eric seperate path pts, and add pause for structure light detection
    detectEveryLayers = 3; % User-define: 3

    E_z_limit=[min(pPathSeq(:,3)),max(pPathSeq(:,3))];
    E_z_sequence=unique(pPathSeq(:,3));
    E_segment_index=0;
    for i=1:detectEveryLayers:length(E_z_sequence) % Calculate the segment index
        E_target_z=E_z_sequence(i);
        E_temporary_index=find(pPathSeq(:,3)==E_target_z);
        E_segment_index=[E_segment_index;E_temporary_index(end)];
    end
    if E_segment_index(end)~=size(pPathSeq,1)
        E_segment_index=[E_segment_index;size(pPathSeq,1)];
    end

    E_cam_offset=[-95,15,135]; % User-define: Each path point adds E_cam_offset;
    for i=1:length(E_segment_index)-1
        pg.enableLaser(printParam.powderMode, printParam.laserDelay);% Open the laser, and open the powder at the same time
        if(length(pFeedrate)==1)
            pg.addPathPtsWithPwr(pPathSeq(E_segment_index(i)+1:E_segment_index(i+1),:), ...
                pwrSeq(E_segment_index(i)+1:E_segment_index(i+1)), ...
                lenPosSeq(E_segment_index(i)+1:E_segment_index(i+1)), ...
                pFeedrate);
        else
            pg.addPathPtsWithPwr(pPathSeq(E_segment_index(i)+1:E_segment_index(i+1),:), ...
                pwrSeq(E_segment_index(i)+1:E_segment_index(i+1)), ...
                lenPosSeq(E_segment_index(i)+1:E_segment_index(i+1)), ...
                pFeedrate(E_segment_index(i)+1:E_segment_index(i+1)));
        end
        pg.disableLaser(printParam.powderMode);% Close the laser, and close the powder at the same time
        pg.addPathPtFeed(pPathSeq(E_segment_index(i+1),:)+E_cam_offset,2000); % 2000 is the moving speed
        pg.addCmd(';;;;;;;;;;;;Structured light detection');
        pg.addCmd('M351P614');
        if E_segment_index(i+1)~=size(pPathSeq,1)
            pg.addPathPtFeed(pPathSeq(E_segment_index(i+1)+1,:),2000); % 2000 is the moving speed
        end
    end
    %% 
    %%% exist printing mode
    pg.disableLaser(printParam.powderMode);
    
    if usingRTCP == 1
        pg.stopRTCP(safetyHeight, 16);        
    end    
    pg.returnToSafety(safetyHeight, obj.sProcessParam_.travelFeedrate);
    
    ret = 1;
end