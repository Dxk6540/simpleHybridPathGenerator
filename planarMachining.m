function retPath = planarMachining(cntr, depthRange, sideLen, machiningLyrThickness, toolRadiu)
    lyrThickness = machiningLyrThickness;
    if(lyrThickness > 0) && (depthRange(1) > depthRange(2))
        lyrThickness = -lyrThickness;
    end
    sideX = sideLen(1);
    sideY = sideLen(2);
    
    passStepOver = toolRadiu*3.5;    
    if floor(sideX/passStepOver) == sideX/passStepOver
        passNum = floor(sideX/passStepOver);            
    else
        passNum = floor(sideX/passStepOver) + 1;    
    end
    passStepOver = sideX / passNum;
    
    xRange = [cntr(1) - sideX/2, cntr(1) + sideX/2];
    yRange = [cntr(2) - sideY/2, cntr(2) + sideY/2];
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

    retPath = planarPathSeq;
end
