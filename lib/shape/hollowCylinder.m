classdef hollowCylinder
    %HOLLOWCYLINDER 此处显示有关此类的摘要
    %   此处显示详细说明
    
   	properties
        shape_="Cylinder";
    end
    methods(Static)
        function [path,pwrSeq,feedrateOffset] = genPrintingPath(cylinderR, startCenter, tol, lyrNum, lyrThickness, pwr, zOffset, channel, step)
            % planar circle path
            lyrPtNum = floor(2 * cylinderR * pi / tol)+1;
            aglStep = 2 * pi / lyrPtNum; 
            path = [];
            pwrSeq = [];
            feedrateOffset = [];
            for lyrIdx = 0 : lyrNum - 1    
                tPathSeq = [];
                tPwrSeq = [];
                if channel > 1
                    for chnIdx = 0 : channel - 1
                        for j = 0 : lyrPtNum - 1
                            x = cos(aglStep * j) * (cylinderR - chnIdx * step) + startCenter(1);
                            y = sin(aglStep * j) * (cylinderR - chnIdx * step) + startCenter(2);
                            z = lyrIdx * lyrThickness + zOffset;
                            speedOffset = (1.025-abs(aglStep * j-0.75*pi)/pi*0.05);
                            tPathSeq = [tPathSeq; x,y,z];
                            tPwrSeq = [tPwrSeq; pwr];
                            feedrateOffset = [feedrateOffset;speedOffset];
                        end
                        tPwrSeq(1)= 0;
                        tPwrSeq(end) = 0;                
                    end
                else
                   for j = 0 : lyrPtNum - 1
                        x = cos(aglStep * j) * cylinderR + startCenter(1);
                        y = sin(aglStep * j) * cylinderR + startCenter(2);
                        z = lyrIdx * lyrThickness + zOffset + j * lyrThickness / lyrPtNum;
                        tPathSeq = [tPathSeq; x,y,z];
                        tPwrSeq = [tPwrSeq; pwr];
                    end
                end
                % stop the power when lift the tool 
                path = [path;tPathSeq];
                pwrSeq = [pwrSeq;tPwrSeq];
            end
            pwrSeq(1) = pwr;
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

