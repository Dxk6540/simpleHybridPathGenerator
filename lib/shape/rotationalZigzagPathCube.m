% date: 20230226
% functions for alternative hybrid manufactuing a cube
% author: Yuanzhi CHEN

classdef rotationalZigzagPathCube
	properties
        shape_="Cube";
    end
    
    methods(Static)
        function [path, bcSeq, pwrSeq, feedOffset] = genPrintingPath(cubeShape, startPoint, lyrNum, lyrThickness, pwr, zOffset, angle, rotation, tilte, step, aus, mode)
            path = [];
            bcSeq = [];
            pwrSeq = [];
            feedOffset = [];
            for lyrIdx = 0 : lyrNum - 1
                zValue = zOffset + lyrThickness * lyrIdx;
                if rotation
                    alpha=angle*lyrIdx/180*pi;                   
                else
                	alpha=angle/180*pi;
                end
                xStep = step/abs(sin(alpha));
                yStep = step/abs(cos(alpha));  
                channel = cubeShape(1)/xStep+cubeShape(2)/yStep;
                for chnIdx = 1 : ceil(channel)-1
                    if(mode==2)
                        if aus && rem(chnIdx,2)==1
                           continue;
                        elseif ~aus && rem(chnIdx,2)==0
                           continue;
                        end
                    end
                    tmpPath = [];
                    tmpPwrSeq = [];
                    deltaX = chnIdx * xStep;
                    deltaY = chnIdx * yStep; 
                    offsetX = 0;
                    offsetY = 0;
                    if cubeShape(1)<deltaX
                        offsetY=(deltaX-cubeShape(1))*abs(tan(alpha));
                        if isnan(offsetY) || deltaX>1e10
                            offsetY=step*chnIdx;
                        end
                        deltaX=cubeShape(1);
                    end
                    if cubeShape(2)<deltaY
                        offsetX=(deltaY-cubeShape(2))*abs(tan(pi/2-alpha));
                        if isnan(offsetX) || deltaY>1e10
                            offsetX=step*chnIdx;
                        end                        
                        deltaY=cubeShape(2);
                    end
                    if offsetX>cubeShape(1)
                       offsetY=0;
                       offsetX=step*chnIdx;
                    end
                    if offsetY>cubeShape(2)
                       offsetX=0;
                       offsetY=step*chnIdx;
                    end
                    trueAngle = rem(angle,360);
                    if 0<=trueAngle && trueAngle<90
                        tmpPath = [tmpPath; startPoint(1) + offsetX, startPoint(2) + deltaY, zValue];
                        tmpPwrSeq = [tmpPwrSeq; 0];
                        tmpPath = [tmpPath; startPoint(1) + offsetX, startPoint(2) + deltaY, zValue];
                        tmpPwrSeq = [tmpPwrSeq; pwr];
                        tmpPath = [tmpPath; startPoint(1) + deltaX, startPoint(2) + offsetY, zValue];
                        tmpPwrSeq = [tmpPwrSeq; pwr];  
                        tmpPath = [tmpPath; startPoint(1) + deltaX, startPoint(2) + offsetY, zValue];
                        tmpPwrSeq = [tmpPwrSeq; 0];
                    elseif 90<=trueAngle && trueAngle<180
                        tmpPath = [tmpPath; startPoint(1) + offsetX, startPoint(2) + cubeShape(2) - deltaY, zValue];
                        tmpPwrSeq = [tmpPwrSeq; 0];
                        tmpPath = [tmpPath; startPoint(1) + offsetX, startPoint(2) + cubeShape(2) - deltaY, zValue];
                        tmpPwrSeq = [tmpPwrSeq; pwr];
                        tmpPath = [tmpPath; startPoint(1) + deltaX, startPoint(2) + cubeShape(2) - offsetY, zValue];
                        tmpPwrSeq = [tmpPwrSeq; pwr];  
                        tmpPath = [tmpPath; startPoint(1) + deltaX, startPoint(2) + cubeShape(2) - offsetY, zValue];
                        tmpPwrSeq = [tmpPwrSeq; 0];
                    elseif 180<=trueAngle && trueAngle<270
                        tmpPath = [tmpPath; startPoint(1) + cubeShape(1) - offsetX, startPoint(2) + cubeShape(2) - deltaY, zValue];
                        tmpPwrSeq = [tmpPwrSeq; 0];
                        tmpPath = [tmpPath; startPoint(1) + cubeShape(1) - offsetX, startPoint(2) + cubeShape(2) - deltaY, zValue];
                        tmpPwrSeq = [tmpPwrSeq; pwr];
                        tmpPath = [tmpPath; startPoint(1) + cubeShape(1) - deltaX, startPoint(2) + cubeShape(2) - offsetY, zValue];
                        tmpPwrSeq = [tmpPwrSeq; pwr];  
                        tmpPath = [tmpPath; startPoint(1) + cubeShape(1) - deltaX, startPoint(2) + cubeShape(2) - offsetY, zValue];
                        tmpPwrSeq = [tmpPwrSeq; 0];                        
                    elseif 270<=trueAngle && trueAngle<360
                        tmpPath = [tmpPath; startPoint(1) + cubeShape(1) - offsetX, startPoint(2) + deltaY, zValue];
                        tmpPwrSeq = [tmpPwrSeq; 0];
                        tmpPath = [tmpPath; startPoint(1) + cubeShape(1) - offsetX, startPoint(2) + deltaY, zValue];
                        tmpPwrSeq = [tmpPwrSeq; pwr];
                        tmpPath = [tmpPath; startPoint(1) + cubeShape(1) - deltaX, startPoint(2) + offsetY, zValue];
                        tmpPwrSeq = [tmpPwrSeq; pwr];  
                        tmpPath = [tmpPath; startPoint(1) + cubeShape(1) - deltaX, startPoint(2) + offsetY, zValue];
                        tmpPwrSeq = [tmpPwrSeq; 0];
                    end
                    sign=-1;
                    if rem(chnIdx,4)==3 || rem(chnIdx,4)==0
                        tmpPath=flipud(tmpPath);
                        tmpPwrSeq=flipud(tmpPwrSeq);
                        sign=1;
                    end
                    path = [path; tmpPath];
                    pwrSeq = [pwrSeq; tmpPwrSeq];
                    bcSeq = [bcSeq; repmat([sign*tilte,alpha/pi*180],length(tmpPath),1)];
                end
            end
                feedOffset = [feedOffset; ones(length(path),1)];
        end
        
        function path = genMachiningPath(cubeShape, startPoint, wpHeight, lyrThickness, toolRadiu, wallOffset, zOffset)
            if floor(wpHeight/lyrThickness) == wpHeight/lyrThickness
                lyrNum = floor(wpHeight/lyrThickness);            
            else
                lyrNum = floor(wpHeight/lyrThickness) + 1;    
            end
            lyrHeight = wpHeight/lyrNum;

            if zOffset > 0
                lyrNum = lyrNum + 6;
            end
            path = [];
            for lyrIdx = 1:lyrNum+1
                z = max(0.1, wpHeight - (lyrIdx - 1) * lyrHeight + zOffset);                
                path = [path; 
                            startPoint(1) - toolRadiu - wallOffset, startPoint(2) - toolRadiu - wallOffset, z;
                            startPoint(1) + cubeShape(1) + toolRadiu + wallOffset, startPoint(2) - toolRadiu - wallOffset, z;
                            startPoint(1) + cubeShape(1) + toolRadiu + wallOffset, startPoint(2) + cubeShape(2) + toolRadiu + wallOffset, z;
                            startPoint(1) - toolRadiu - wallOffset, startPoint(2)  + cubeShape(2) + toolRadiu + wallOffset, z;
                            startPoint(1) - toolRadiu - wallOffset, startPoint(2) - toolRadiu - wallOffset, z;];
            end         
        end
    end
end
