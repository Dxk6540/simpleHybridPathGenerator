function [path, feedSeq] = planarCircleMachining(cntr, depthRange, radiuRng, mLyrThick, toolRadiu, feedrate, slowFeed)
    lyrThickness = mLyrThick;
    
    passStepOver = toolRadiu*1.6; 
    radiuDiffLen = abs(radiuRng(1) - radiuRng(2));
    if floor(radiuDiffLen/passStepOver) == radiuDiffLen/passStepOver
        passNum = floor(radiuDiffLen/passStepOver);            
    else
        passNum = floor(radiuDiffLen/passStepOver) + 1;    
    end
    passStepOver = radiuDiffLen / passNum;    
    tol = 1;
    mPathSeq = [];
    feedSeq = [];
    for zPos = depthRange(1): lyrThickness: depthRange(2)    
        for curR = radiuRng(1): passStepOver: radiuRng(2)
            % planar circle path
            lyrPtNum = floor(2 * curR * pi / tol)+1;
            aglStep = 2 * pi / lyrPtNum;
            for j = 0 : lyrPtNum
                x = cos(aglStep * j) * curR + cntr(1);
                y = sin(aglStep * j) * curR + cntr(2);
                mPathSeq = [mPathSeq; x,y,zPos];
                feedSeq = [feedSeq; feedrate];
            end
        end
        mPathSeq = [mPathSeq; x,y,zPos];
        feedSeq = [feedSeq; slowFeed];
        mPathSeq = [mPathSeq; x,y,zPos + lyrThickness];
        feedSeq = [feedSeq; slowFeed];        
    end
    path = mPathSeq;  
end

