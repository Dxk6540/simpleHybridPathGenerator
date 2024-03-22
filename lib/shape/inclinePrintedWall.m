% date: 20230515
% functions for incline single channel wall
% author: Yuanzhi CHEN

classdef inclinePrintedWall
	properties
        shape_="Wall";
    end
    
    methods(Static)
        function [path, pwrSeq] = genPrintingPath(length, startPoint, lead, lyrNum, lyrThickness, pwr, incline, channel, step)
%             cubeShape: (1) is the length along x direction and (2) is the
%             channel number.
            path = [];
            pwrSeq = [];
            feedOffset = [];
            y=startPoint(2);
            for lyrIdx = 0 : lyrNum - 1
                cPathSeq = [];
                cPwrSeq = [];
                for chnIdx = 0 : channel - 1
                    x=startPoint(1) + chnIdx * step;
                    zValue = lyrThickness * lyrIdx;
                    tmpPath = [];
                    tmpPwrSeq = [];
                    tmpPath = [tmpPath; x, startPoint(2)-lead, zValue,incline,0];
                    tmpPwrSeq = [tmpPwrSeq; 0];
                    tmpPath = [tmpPath; x, startPoint(2)-0.1, zValue,incline,0];
                    tmpPwrSeq = [tmpPwrSeq; 0];
                    tmpPath = [tmpPath; x, startPoint(2), zValue,incline,0];
                    tmpPwrSeq = [tmpPwrSeq; pwr];
                    tmpPath = [tmpPath; x, startPoint(2) + length, zValue,incline,0];
                    tmpPwrSeq = [tmpPwrSeq; pwr];
                    tmpPath = [tmpPath; x, startPoint(2) + length + 0.1, zValue,incline,0];
                    tmpPwrSeq = [tmpPwrSeq; 0];
                    tmpPath = [tmpPath; x, startPoint(2) + length + lead, zValue,incline,0];
                    tmpPwrSeq = [tmpPwrSeq; 0];
                    if rem(chnIdx,2)==1
                        tmpPath=flipud(tmpPath);
                        tmpPwrSeq=flipud(tmpPwrSeq);
                    end
                    cPathSeq = [cPathSeq; tmpPath];
                    cPwrSeq = [cPwrSeq; tmpPwrSeq];
                end
                if rem(lyrIdx,2)==1
                    cPathSeq=flipud(cPathSeq);
                    cPwrSeq=flipud(cPwrSeq);
                end
                path = [path; cPathSeq];
                pwrSeq = [pwrSeq; cPwrSeq];
            end
        end
    end
end
