% date: 20230515
% functions for incline single channel wall
% author: Yuanzhi CHEN

classdef inclineWall
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
                    zValue = sin(incline/180*pi)*x+cos(incline/180*pi)*lyrThickness * lyrIdx;
                    tmpPath = [];
                    tmpPwrSeq = [];
                    inclineX=cos(incline/180*pi)*x-sin(incline/180*pi)*lyrThickness * lyrIdx;
                    tmpPath = [tmpPath; inclineX, startPoint(2)-lead, zValue];
                    tmpPwrSeq = [tmpPwrSeq; 0];
                    tmpPath = [tmpPath; inclineX, startPoint(2)-0.1, zValue];
                    tmpPwrSeq = [tmpPwrSeq; 0];
                    tmpPath = [tmpPath; inclineX, startPoint(2), zValue];
                    tmpPwrSeq = [tmpPwrSeq; pwr];
                    tmpPath = [tmpPath; inclineX, startPoint(2) + length, zValue];
                    tmpPwrSeq = [tmpPwrSeq; pwr];
                    tmpPath = [tmpPath; inclineX, startPoint(2) + length + 0.1, zValue];
                    tmpPwrSeq = [tmpPwrSeq; 0];
                    tmpPath = [tmpPath; inclineX, startPoint(2) + length + lead, zValue];
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
            end
        end
    end
end
