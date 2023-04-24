% date: 20230226
% functions for alternative hybrid manufactuing a cube
% author: Yuanzhi CHEN

classdef rotationalZigzagPathCube
	properties
        shape_="Cube";
    end
    
    methods(Static)
        function [path, pwrSeq, feedOffset] = genPrintingPath(cubeShape, startPoint, lyrNum, lyrThickness, pwr, zOffset, angle, rotation, step)
%             cubeShape: (1) is the length along x direction and (2) is the
%             channel number.
            path = [];
            pwrSeq = [];
            feedOffset = [];            
            for lyrIdx = 0 : lyrNum - 1
                zValue = zOffset + lyrThickness * lyrIdx;
                if rotation
                    alpha=angle*lyrIdx;                   
                else
                  alpha=angle;
                end
                xStep = step/abs(sin(alpha/180*pi));
                yStep = step/abs(cos(alpha/180*pi));  
                channel = max(cubeShape(1)/xStep,cubeShape(2)/yStep);
                for chnIdx = 1 : channel-1
                    tmpPath = [];
                    tmpPwrSeq = [];
                    deltaX = chnIdx * xStep;
                    deltaY = chnIdx * yStep; 
                    offsetX = 0;
                    offsetY = 0;
                    if cubeShape(1)<chnIdx * xStep
                        deltaX=cubeShape(1);
                        offsetX=(chnIdx * xStep-cubeShape(1))/tan(pi/2-alpha);
                    end
                    if cubeShape(2)<chnIdx * yStep
                        deltaY=cubeShape(2);
                        offsetY=(chnIdx * yStep-cubeShape(2))/tan(alpha);
                    end
                    if offsetX>cubeShape(1)
                       offsetX=0;
                       offsetY=step*chnIdx;
                    end
                    if offsetY>cubeShape(2)
                       offsetY=0;
                       offsetX=step*chnIdx;
                    end
                    tmpPath = [tmpPath; startPoint(1) + offsetX, startPoint(2) + deltaY, zValue];
                    tmpPwrSeq = [tmpPwrSeq; pwr];
                    tmpPath = [tmpPath; startPoint(1) + deltaX, startPoint(2) + offsetY, zValue];
                    tmpPwrSeq = [tmpPwrSeq; pwr];  
                    if rem(chnIdx,2)==1
                        tmpPath=flipud(tmpPath);
                        tmpPwrSeq=flipud(tmpPwrSeq);
                    end
                    path = [path; tmpPath];
                    pwrSeq = [pwrSeq; tmpPwrSeq];
                end
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
