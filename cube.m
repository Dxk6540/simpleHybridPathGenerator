% date: 20230226
% functions for alternative hybrid manufactuing a cylinder
% author: Xiaoke DENG

classdef cube
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
                    cPathSeq = [cPathSeq; startPoint(1),startPoint(2) + chnIdx * step,zOffset+lyrThickness*lyrIdx];
                    cPwrSeq = [cPwrSeq; 0];
                    cPathSeq = [cPathSeq; startPoint(1) + tol,startPoint(2) + chnIdx * step,zOffset+lyrThickness*lyrIdx];
                    cPwrSeq = [cPwrSeq; pwr];
                    cPathSeq = [cPathSeq; startPoint(1) + cubeLength - tol,startPoint(2) + chnIdx * step,zOffset+lyrThickness*lyrIdx];
                    cPwrSeq = [cPwrSeq; pwr];
                    cPathSeq = [cPathSeq; startPoint(1) + cubeLength,startPoint(2) + chnIdx * step,zOffset+lyrThickness*lyrIdx];
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
        
        function path = genMachiningPath(cylinderR, startCenter, tol, wpHeight, lyrThickness, toolRadiu, wallOffset, zOffset)
            path=[0,0,0];
        end
    end
end
