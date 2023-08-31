% date: 20230626
% functions for alternative hybrid manufactuing a cube
% author: Yuanzhi CHEN

classdef zigzagWall
	properties
        shape_="Wall";
    end
    
    methods(Static)
        function [path, pwrSeq, feedOffset] = genPrintingPath(wallLength, startPoint, lead, lyrNum, lyrThickness, pwr, zOffset, channel, step)
            path = [];
            pwrSeq = [];
            feedOffset = []; 
            tol = 0.1;
            for lyrIdx = 0 : lyrNum - 1
                zValue = zOffset + lyrThickness * lyrIdx;
                cPathSeq = [];
                cPwrSeq = [];
                for chnIdx = 0 : channel - 1
                    tmpPath = [];
                    tmpPwrSeq = [];
                    tmpPath = [tmpPath; startPoint(1) - lead, startPoint(2) + chnIdx * step, zValue];
                    tmpPwrSeq = [tmpPwrSeq; 0];
                    tmpPath = [tmpPath; startPoint(1) - tol, startPoint(2) + chnIdx * step, zValue];
                    tmpPwrSeq = [tmpPwrSeq; 0];
                    tmpPath = [tmpPath; startPoint(1), startPoint(2) + chnIdx * step, zValue];
                    tmpPwrSeq = [tmpPwrSeq; pwr];
                    tmpPath = [tmpPath; startPoint(1) + wallLength, startPoint(2) + chnIdx * step, zValue];
                    tmpPwrSeq = [tmpPwrSeq; pwr];
                    tmpPath = [tmpPath; startPoint(1) + wallLength - tol, startPoint(2) + chnIdx * step, zValue];
                    tmpPwrSeq = [tmpPwrSeq; 0];
                    tmpPath = [tmpPath; startPoint(1) + wallLength + lead, startPoint(2) + chnIdx * step, zValue];
                    tmpPwrSeq = [tmpPwrSeq; 0];
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
        
        function [path,feedrateSeq] = genMachiningPath(wallLength, wallWidth, startPoint, feedrate, traversalSpeed, toolRadiu, wallOffset, depth, zOffset)      
            zOffset = max(0.5,zOffset);
            path=[];
            feedrateSeq=[];
            for idx=wallOffset:-depth:0
                path = [path; startPoint(1) - idx - toolRadiu, startPoint(2) - toolRadiu, zOffset;
                        startPoint(1) - idx - toolRadiu, startPoint(2) + wallWidth + toolRadiu, zOffset;];
                feedrateSeq = [feedrateSeq; feedrate; feedrate];
            end
            path = [path; startPoint(1) + wallLength + wallOffset + toolRadiu, startPoint(2) + wallWidth + toolRadiu, zOffset;];
            feedrateSeq = [feedrateSeq; traversalSpeed];
            for idx=wallOffset:-depth:0
                path = [path; startPoint(1) + wallLength + idx + toolRadiu, startPoint(2) - toolRadiu, zOffset;
                        startPoint(1) + wallLength + idx + toolRadiu, startPoint(2) + wallWidth + toolRadiu, zOffset;];
                feedrateSeq = [feedrateSeq; feedrate; feedrate];
            end
        end
    end
end
