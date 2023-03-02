function ret = planarMachining(cntr, depthRange, side, machiningLyrThickness, toolRadiu)
    lyrThickness = machiningLyrThickness;
    
    passStepOver = toolRadiu*3.5;    
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
                             xRange(2), yPos + passStepOver/2, zPos;                             
                             xRange(1), yPos + passStepOver/2, zPos];            
        end
    end

    ret = planarPathSeq;
end
