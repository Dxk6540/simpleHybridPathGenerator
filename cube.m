% date: 20230226
% functions for alternative hybrid manufactuing a cube
% author: Yuanzhi CHEN

classdef cube
	properties
        shape_="Cube";
    end
    
    methods(Static)
        function [path, pwrSeq, feedOffset] = genPrintingPath(cubeLength, startPoint, tol, lyrNum, lyrThickness, pwr, zOffset, ~, step)
            path = [];
            pwrSeq = [];
            feedOffset = [];
            outPathSeq = [];
            outPathSeq = [outPathSeq;startPoint(1), startPoint(2), zOffset];
            outPathSeq = [outPathSeq;startPoint(1) + tol, startPoint(2), zOffset];
            outPathSeq = [outPathSeq;startPoint(1) + cubeLength(1), startPoint(2), zOffset];
            outPathSeq = [outPathSeq;startPoint(1) + cubeLength(1), startPoint(2) + cubeLength(2), zOffset];
            outPathSeq = [outPathSeq;startPoint(1), startPoint(2) + cubeLength(2), zOffset];
            outPathSeq = [outPathSeq;startPoint(1), startPoint(2) + step, zOffset];
            outPwrSeq = 1.2 * pwr * ones(length(outPathSeq),1);
            startPoint = startPoint + [step, step];
            for lyrIdx = 0 : lyrNum - 1
                zValue = zOffset + lyrThickness * lyrIdx;
                tPathSeq = outPathSeq + [0,0,lyrThickness * lyrIdx];
                tPwrSeq = outPwrSeq;
                channel = cubeLength(2) - step;
                for chnIdx = 0 : channel - 1
                    cPathSeq = [];
                    cPwrSeq = [];
                    cPathSeq = [cPathSeq; startPoint(1) + tol, startPoint(2) + chnIdx * step, zValue];
                    cPwrSeq = [cPwrSeq; pwr];
                    cPathSeq = [cPathSeq; startPoint(1) + step, startPoint(2) + chnIdx * step, zValue];
                    cPwrSeq = [cPwrSeq; pwr];
                    cPathSeq = [cPathSeq; startPoint(1) + cubeLength(1) - 2 * step, startPoint(2) + chnIdx * step, zValue];
                    cPwrSeq = [cPwrSeq; pwr];
                    cPathSeq = [cPathSeq; startPoint(1) + cubeLength(1) - 2 * step + tol, startPoint(2) + chnIdx * step, zValue];
                    cPwrSeq = [cPwrSeq; pwr];
                    if rem(chnIdx,2)==1
                        cPathSeq=flipud(cPathSeq);
                        cPwrSeq=flipud(cPwrSeq);
                    end
                    tPathSeq = [tPathSeq; cPathSeq];
                    tPwrSeq = [tPwrSeq; cPwrSeq];
                end
                tPwrSeq(end) = 0;
                tPathSeq = [tPathSeq;tPathSeq(1,:)-[0,tol,0]];
                tPwrSeq = [tPwrSeq; 0];
                path = [path; tPathSeq];
                pwrSeq = [pwrSeq; tPwrSeq];
                feedOffset = [feedOffset; (1 - lyrIdx * 0.005)* ones(length(tPathSeq),1)];
            end
        end
        
        function path = genMachiningPath(cubeLength, cubeWidth, startPoint, tol, wpHeight, lyrThickness, toolRadiu, wallOffset, zOffset, side)
            path=[0,0,0];
            
            if floor(wpHeight/lyrThickness) == wpHeight/lyrThickness
                lyrNum = floor(wpHeight/lyrThickness);            
            else
                lyrNum = floor(wpHeight/lyrThickness) + 1;    
            end
            lyrHeight = wpHeight/lyrNum;

            if zOffset > 0
                lyrNum = lyrNum + 6;
            end
            mPathSeq = [];
            for lyrIdx = 1:1:lyrNum+1
                z = max(0.1, wpHeight - (lyrIdx - 1) * lyrHeight + zOffset);                
                mPathSeq = [mPathSeq; 
                            startPoint(1) - toolRadiu - wallOffset, startPoint(2) - toolRadiu - wallOffset, z;
                            startPoint(1) + cubeLength + toolRadiu + wallOffset, startPoint(2) - toolRadiu - wallOffset, z;
                            startPoint(1) + cubeLength + toolRadiu + wallOffset, startPoint(2) + cubeWidth + toolRadiu + wallOffset, z;
                            startPoint(1) - toolRadiu - wallOffset, startPoint(2)  + cubeWidth + toolRadiu + wallOffset, z;
                            startPoint(1) - toolRadiu - wallOffset, startPoint(2) - toolRadiu - wallOffset, z;];
            end
            path = mPathSeq;            
            
        end
    end
end
