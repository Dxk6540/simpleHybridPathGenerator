function ret = genCamMtPrintingProcess(obj, pg, pPathSeq, pwrSeq, pFeedrate, printParam)
    pwr = printParam.pwr; % 1.2KW / 4kw *1000;
    lenPos = printParam.lenPos;
    flowL = printParam.flowL; % 6 L/min / 20L/min * 1000;
    speedL = printParam.speedL;% 2 r/min / 10r/min * 1000;
    flowR = printParam.flowR;% 6 L/min / 20L/min * 1000;
    speedR = printParam.speedR;% 2 r/min / 10r/min * 1000;
    lenPosSeq = ones(length(pPathSeq),1) * printParam.lenPos;
    
    safetyHeight = obj.sProcessParam_.safetyHeight;

    %%% start printing mode
    pg.changeMode(1); % change to printing mode
    pg.setLaser(pwr, lenPos, flowL, speedL, flowR, speedR); % set a init process param (in case of overshoot)
%     pg.saftyToPt([nan, nan, safetyHeight], [startCtr(1) + radius, startCtr(2), 0], 3000); % safety move the start pt
    pg.saftyToPt([nan, nan, safetyHeight], pPathSeq(1,:), obj.sProcessParam_.travelFeedrate); % safety move the start pt
    if pg.alternation_==1
        pg.pauseProgramMust();
    else
        pg.pauseProgram();% pause and wait for start (the button)
    end

    %Eric seperate path pts, and add pause for structure light detection
    E_z_limit=[min(pPathSeq(:,3)),max(pPathSeq(:,3))];
    E_z_sequence=unique(pPathSeq(:,3));
    E_segment_index=0;
    for i=1:3:length(E_z_sequence) % Calculate the segment index
        E_target_z=E_z_sequence(i);
        E_temporary_index=find(pPathSeq(:,3)==E_target_z);
        E_segment_index=[E_segment_index;E_temporary_index(end)];
    end
    if E_segment_index(end)~=size(pPathSeq,1)
        E_segment_index=[E_segment_index;size(pPathSeq,1)];
    end

% Eric Test
%     E_segments={};
%     for i=1:length(E_segment_index)-1
%         E_segments{i}{1}=pPathSeq(E_segment_index(i)+1:E_segment_index(i+1),:);
%         E_segments{i}{2}=pwrSeq(E_segment_index(i)+1:E_segment_index(i+1));
%         E_segments{i}{3}=lenPosSeq(E_segment_index(i)+1:E_segment_index(i+1));
%         E_segments{i}{4}=pFeedrate(E_segment_index(i)+1:E_segment_index(i+1));
%     end
%     if E_segment_index(end)~=size(pPathSeq,1)
%         E_segments{length(E_segment_index)}{1}=pPathSeq(E_segment_index(end)+1:size(pPathSeq,1),:);
%         E_segments{length(E_segment_index)}{2}=pwrSeq(E_segment_index(end)+1:size(pPathSeq,1));
%         E_segments{length(E_segment_index)}{3}=lenPosSeq(E_segment_index(end)+1:size(pPathSeq,1));
%         E_segments{length(E_segment_index)}{4}=pFeedrate(E_segment_index(end)+1:size(pPathSeq,1));
%     end
    
    E_cam_offset=[-95,15,135];
    for i=1:length(E_segment_index)-1
        pg.enableLaser(printParam.powderMode, printParam.laserDelay);
        pg.addPathPtsWithPwr(pPathSeq(E_segment_index(i)+1:E_segment_index(i+1),:), ...
            pwrSeq(E_segment_index(i)+1:E_segment_index(i+1)), ...
            lenPosSeq(E_segment_index(i)+1:E_segment_index(i+1)), ...
            pFeedrate(E_segment_index(i)+1:E_segment_index(i+1)));
        pg.disableLaser(printParam.powderMode);
        pg.addPathPt(pPathSeq(E_segment_index(i+1),:)+E_cam_offset);
        pg.addCmd(';;;;;;;;;;;;Structured light detection');
        pg.pauseProgramMust();
        if E_segment_index(i+1)~=size(pPathSeq,1)
            pg.addPathPt(pPathSeq(E_segment_index(i+1)+1,:));
        end
    end

    % pg.addPathPtsWithPwr(pPathSeq, pwrSeq, lenPosSeq, pFeedrate);
%        pg.disableLaser(printParam.powderMode);


    %%% exist printing mode
 
    pg.returnToSafety(safetyHeight, obj.sProcessParam_.travelFeedrate);
    
    ret = 1;
    
end