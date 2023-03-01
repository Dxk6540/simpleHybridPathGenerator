% date: 20230226
% functions for alternative hybrid manufactuing a vase
% author: Yuanzhi CHEN

classdef vase
    methods(Static)
        function [path,pwrSeq] = genPrintingPath(vaseEnlarge, startCenter, tol, lyrNum, lyrThickness, pwr, zOffset, channel, step)
            % planar circle path
            path = [];
            pwrSeq = [];
            for lyrIdx = 0 : lyrNum - 1    
                tPathSeq = [];
                tPwrSeq = [];
                radius = vaseEnlarge * vase.genVaseRadius(lyrIdx * lyrThickness);
                lyrPtNum = floor(2 * radius * pi / tol)+1;
                aglStep = 2 * pi / lyrPtNum;
                if channel > 1
                    for chnIdx = 0 : channel - 1
                        for j = 0 : lyrPtNum - 1
                            x = cos(aglStep * j) * (radius - chnIdx * step) + startCenter(1);
                            y = sin(aglStep * j) * (radius - chnIdx * step) + startCenter(2);
                            z = lyrIdx * lyrThickness + zOffset;
                            tPathSeq = [tPathSeq; x,y,z];
                            tPwrSeq = [tPwrSeq; pwr];
                        end
                        tPwrSeq(1)= 0;
                        tPwrSeq(end) = 0;                
                    end
                else
                   for j = 0 : lyrPtNum - 1
                        x = cos(aglStep * j) * radius + startCenter(1);
                        y = sin(aglStep * j) * radius + startCenter(2);
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
        
        function path = genMachiningPath(vaseEnlarge, startCenter, tol, wpHeight, lyrThickness, toolRadiu, wallOffset, zOffset, side)
            path=[0,0,0];
        end
        
        function radius = genVaseRadius(zValue)
            radius = 3.5 * (sin(((((zValue)/(7.5))+46)/(2)))+1.5 * sin(((((zValue)/(7.5))+46)/(4))+45)+2 * cos(((((zValue)/(7.5))+46)/(6)))+7);
        end
    end
end
