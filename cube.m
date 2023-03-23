% date: 20230226
% functions for alternative hybrid manufactuing a cube
% author: Yuanzhi CHEN

classdef cube
	properties
        shape_="Cube";
    end
    
    methods(Static)
        function [path,pwrSeq] = genPrintingPath(cubeLength, startPoint, tol, lyrNum, lyrThickness, pwr, zOffset, channel, step)
            path = [];
            pwrSeq = [];
            for lyrIdx = 0 : lyrNum - 1
                tPathSeq = [];
                tPwrSeq = [];
                for chnIdx = 0 : channel - 1
                    cPathSeq = [];
                    cPwrSeq = [];
                    cPathSeq = [cPathSeq; startPoint(1), startPoint(2) + chnIdx * step, zOffset+lyrThickness*lyrIdx];
                    cPwrSeq = [cPwrSeq; 0];
                    cPathSeq = [cPathSeq; startPoint(1) + tol, startPoint(2) + chnIdx * step, zOffset+lyrThickness*lyrIdx];
                    cPwrSeq = [cPwrSeq; pwr];
                    cPathSeq = [cPathSeq; startPoint(1) + cubeLength - tol, startPoint(2) + chnIdx * step, zOffset+lyrThickness*lyrIdx];
                    cPwrSeq = [cPwrSeq; pwr];
                    cPathSeq = [cPathSeq; startPoint(1) + cubeLength, startPoint(2) + chnIdx * step, zOffset+lyrThickness*lyrIdx];
                    cPwrSeq = [cPwrSeq; 0];
                    if rem(chnIdx,2)==1
                        cPathSeq=flipud(cPathSeq);
                        cPwrSeq=flipud(cPwrSeq);
                    end
                    tPathSeq = [tPathSeq; cPathSeq];
                    tPwrSeq = [tPwrSeq; cPwrSeq];
                end
                if rem(lyrIdx,2)==1
                    tPathSeq=flipud(tPathSeq);
                    tPwrSeq=flipud(tPwrSeq);
                end
                path = [path; tPathSeq];
                pwrSeq = [pwrSeq; tPwrSeq];
            end
            pwrSeq(1) = pwr;
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
