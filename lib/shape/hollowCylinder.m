classdef hollowCylinder
    %HOLLOWCYLINDER 此处显示有关此类的摘要
    %   此处显示详细说明
    
   	properties
        shape_="Cylinder";
    end
    methods(Static)
        function [path,pwrSeq,feedrateOffset] = genPrintingPath(cylinderR, startCenter, tol, lyrNum, lyrThickness, pwr, zOffset, channel, step, inLayerShift, interShift, leanAngle)
            % planar circle path
            inLayerShiftPtNum = round(inLayerShift/tol);
            interShiftPtNum = round(interShift/tol);
            lyrPtNum = floor(2 * cylinderR * pi / tol)+1;
            aglStep = 2 * pi / lyrPtNum; 
            path = [];
            pwrSeq = [];
            feedrateOffset = [];
            for lyrIdx = 0 : lyrNum - 1    
                tPathSeq = [];
                tPwrSeq = [];
                for chnIdx = 0 : channel - 1
                    firstPt = lyrIdx*interShiftPtNum+chnIdx*inLayerShiftPtNum;
                    lastPt = lyrPtNum  + firstPt;
                    x = cos(aglStep * firstPt) * (cylinderR - chnIdx * step) + startCenter(1) + sin(aglStep * firstPt)*interShift;
                    y = sin(aglStep * firstPt) * (cylinderR - chnIdx * step) + startCenter(2) - cos(aglStep * firstPt)*interShift;
                    z = lyrIdx * lyrThickness + zOffset;
                    b = 0;
                    c = (aglStep * firstPt)*180/pi;
                    tPathSeq = [tPathSeq; x,y,z,b,c];
                    tPwrSeq = [tPwrSeq; 0];
                    feedrateOffset = [feedrateOffset;1];
                    for j = firstPt : lastPt
                        x = cos(aglStep * j) * (cylinderR - chnIdx * step) + startCenter(1);
                        y = sin(aglStep * j) * (cylinderR - chnIdx * step) + startCenter(2);
                        z = lyrIdx * lyrThickness + zOffset;
                        if chnIdx == 0
                            b = leanAngle;
                            c = (aglStep * j)*180/pi;
                        elseif chnIdx == channel - 1
                            b = -leanAngle;
                            c = (aglStep * j)*180/pi;
                        else
                            b=0;
                            c=0;
                        end
                        speedOffset = 1;
                        if j == firstPt
                            tPathSeq = [tPathSeq; x,y,z,b,c];
                            tPwrSeq = [tPwrSeq; 0];
                            feedrateOffset = [feedrateOffset;speedOffset];
                        end
                        tPathSeq = [tPathSeq; x,y,z,b,c];
                        tPwrSeq = [tPwrSeq; pwr];
                        feedrateOffset = [feedrateOffset;speedOffset];
                        if j == lastPt
                            tPathSeq = [tPathSeq; x,y,z,b,c];
                            tPwrSeq = [tPwrSeq; 0];
                            feedrateOffset = [feedrateOffset;speedOffset];
                        end                        
                    end
                    x = cos(aglStep * lastPt) * (cylinderR - chnIdx * step) + startCenter(1) - sin(aglStep * firstPt)*interShift;
                    y = sin(aglStep * lastPt) * (cylinderR - chnIdx * step) + startCenter(2) + cos(aglStep * firstPt)*interShift;
                    z = lyrIdx * lyrThickness + zOffset;
                    b = 0;
                    c = (aglStep * firstPt)*180/pi;
                    tPathSeq = [tPathSeq; x,y,z,b,c];
                    tPwrSeq = [tPwrSeq; 0];
                    feedrateOffset = [feedrateOffset;1];             
                end
                % stop the power when lift the tool 
                path = [path;tPathSeq];
                pwrSeq = [pwrSeq;tPwrSeq];
            end
        end

        function path = genMachiningPath(cylinderR, startCenter, tol, wpHeight, lyrThickness, toolRadiu, wallOffset, zOffset, side)
            % planar circle path
            lyrPtNum = floor(2 * (cylinderR + side*(toolRadiu + wallOffset)) * pi / tol)+1;
            % wpHeight = lyrNum * lyrHeight;
            if floor(wpHeight/lyrThickness) == wpHeight/lyrThickness
                lyrNum = floor(wpHeight/lyrThickness);            
            else
                lyrNum = floor(wpHeight/lyrThickness) + 1;    
            end
            lyrHeight = wpHeight/lyrNum;

            if zOffset > 0
                lyrNum = lyrNum + 6;
            end

            aglStep = 2 * pi / lyrPtNum;
            mPathSeq = [];
            for lyrIdx = 1:lyrNum+1
            %     centerXOffset = ((lyrIdx - 1) * lyrHeight) * tan(inclinationAgl/180 * pi); 
                for j = 1 : lyrPtNum
            %         x = cos(aglStep * j) * radius + startCenter(1) + centerXOffset;
                    x = cos(aglStep * j) * (cylinderR + side*(toolRadiu + wallOffset)) + startCenter(1);
                    y = sin(aglStep * j) * (cylinderR + side*(toolRadiu + wallOffset)) + startCenter(2);
                    z = max(0.06, wpHeight - (lyrIdx - 1) * lyrHeight + zOffset);
                    mPathSeq = [mPathSeq; x,y,z];
                end
            end
            path = mPathSeq;
        end
    end
end

