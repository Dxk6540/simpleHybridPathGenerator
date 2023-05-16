% date: 20230226
% functions for alternative hybrid manufactuing a cube
% author: Yuanzhi CHEN

classdef zigzagPathCube
	properties
        shape_="Cube";
    end
    
    methods(Static)
        function [path, pwrSeq, feedOffset] = genPrintingPath(cubeShape, startPoint, tol, lyrNum, lyrThickness, pwr, zOffset, ~, step)
%             cubeShape: (1) is the length along x direction and (2) is the
%             channel number.
            path = [];
            pwrSeq = [];
            feedOffset = [];            
            for lyrIdx = 0 : lyrNum - 1
                zValue = zOffset + lyrThickness * lyrIdx;
%                 channel = cubeShape(2) - step;
                channel = cubeShape(2);
                cPathSeq = [];
                cPwrSeq = [];
                for chnIdx = 0 : channel - 1
                    tmpPath = [];
                    tmpPwrSeq = [];
                    tmpPath = [tmpPath; startPoint(1) + tol, startPoint(2) + chnIdx * step, zValue];
                    tmpPwrSeq = [tmpPwrSeq; pwr];
                    tmpPath = [tmpPath; startPoint(1) + step, startPoint(2) + chnIdx * step, zValue];
                    tmpPwrSeq = [tmpPwrSeq; pwr];
                    tmpPath = [tmpPath; startPoint(1) + cubeShape(1) - 2 * step, startPoint(2) + chnIdx * step, zValue];
                    tmpPwrSeq = [tmpPwrSeq; pwr];
                    tmpPath = [tmpPath; startPoint(1) + cubeShape(1) - 2 * step + tol, startPoint(2) + chnIdx * step, zValue];
                    tmpPwrSeq = [tmpPwrSeq; pwr];
                    if rem(chnIdx,2)==1
                        tmpPath=flipud(tmpPath);
                        tmpPwrSeq=flipud(tmpPwrSeq);
                    end
                    cPathSeq = [cPathSeq; tmpPath];
                    cPwrSeq = [cPwrSeq; tmpPwrSeq];
                end
                path = [path; cPathSeq];
                pwrSeq = [pwrSeq; cPwrSeq];
                feedOffset = [feedOffset; ones(length(path),1)];
            end
        end
        
        function path = genMachiningPath(cubeShape, cubeWidth, startPoint, tol, wpHeight, lyrThickness, toolRadiu, wallOffset, zOffset, side)
%             path=[0,0,0];
%             
%             if floor(wpHeight/lyrThickness) == wpHeight/lyrThickness
%                 lyrNum = floor(wpHeight/lyrThickness);            
%             else
%                 lyrNum = floor(wpHeight/lyrThickness) + 1;    
%             end
%             lyrHeight = wpHeight/lyrNum;
% 
%             if zOffset > 0
%                 lyrNum = lyrNum + 6;
%             end
%             mPathSeq = [];
%             for lyrIdx = 1:1:lyrNum+1
%                 z = max(0.1, wpHeight - (lyrIdx - 1) * lyrHeight + zOffset);                
%                 mPathSeq = [mPathSeq; 
%                             startPoint(1) - toolRadiu - wallOffset, startPoint(2) - toolRadiu - wallOffset, z;
%                             startPoint(1) + cubeShape + toolRadiu + wallOffset, startPoint(2) - toolRadiu - wallOffset, z;
%                             startPoint(1) + cubeShape + toolRadiu + wallOffset, startPoint(2) + cubeWidth + toolRadiu + wallOffset, z;
%                             startPoint(1) - toolRadiu - wallOffset, startPoint(2)  + cubeWidth + toolRadiu + wallOffset, z;
%                             startPoint(1) - toolRadiu - wallOffset, startPoint(2) - toolRadiu - wallOffset, z;];
%             end
%             path = mPathSeq;            
            
        end
    end
end
