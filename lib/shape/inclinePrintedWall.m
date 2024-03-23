% date: 20230515
% functions for incline single channel wall
% author: Yuanzhi CHEN

classdef inclinePrintedWall
	properties
        shape_="Wall";
    end
    
    methods(Static)
        function [path, pwrSeq] = genPrintingPath(length, startPoint, lead, lyrNum, lyrThickness, pwr, incline, channel, step, lean)
%             cubeShape: (1) is the length along x direction and (2) is the
%             channel number.
            path = [];
            pwrSeq = [];
            feedOffset = [];
            y=startPoint(2);
            lean = -lean;
            for lyrIdx = 0 : lyrNum - 1
                cPathSeq = [];
                cPwrSeq = [];
                cAxisSeq = [];
                for chnIdx = 0 : channel - 1
                    x=startPoint(1) + chnIdx * step;
                    zValue = lyrThickness * lyrIdx;
                    tmpPath = [];
                    tmpPwrSeq = [];
                    tmpAxisSeq = [];
                    tmpPath = [tmpPath; x, startPoint(2)-lead, zValue];
                    tmpPwrSeq = [tmpPwrSeq; 0];
                    tmpAxisSeq = [tmpAxisSeq;(roty(incline/180*pi)*rotx(lean/180*pi)*[0,0,1]')'];
                    tmpPath = [tmpPath; x, startPoint(2)-0.1, zValue];
                    tmpPwrSeq = [tmpPwrSeq; 0];
                    tmpAxisSeq = [tmpAxisSeq;(roty(incline/180*pi)*rotx(lean/180*pi)*[0,0,1]')'];
                    tmpPath = [tmpPath; x, startPoint(2), zValue];
                    tmpPwrSeq = [tmpPwrSeq; pwr];
                    tmpAxisSeq = [tmpAxisSeq;(roty(incline/180*pi)*rotx(lean/180*pi)*[0,0,1]')'];
                    tmpPath = [tmpPath; x, startPoint(2) + length, zValue];
                    tmpPwrSeq = [tmpPwrSeq; pwr];
                    tmpAxisSeq = [tmpAxisSeq;(roty(incline/180*pi)*rotx(lean/180*pi)*[0,0,1]')'];
                    tmpPath = [tmpPath; x, startPoint(2) + length + 0.1, zValue];
                    tmpPwrSeq = [tmpPwrSeq; 0];
                    tmpAxisSeq = [tmpAxisSeq;(roty(incline/180*pi)*rotx(lean/180*pi)*[0,0,1]')'];
                    tmpPath = [tmpPath; x, startPoint(2) + length + lead, zValue];
                    tmpPwrSeq = [tmpPwrSeq; 0];
                    tmpAxisSeq = [tmpAxisSeq;(roty(incline/180*pi)*rotx(lean/180*pi)*[0,0,1]')'];
                    if rem(chnIdx,2)==0
                        tmpPath=flipud(tmpPath);
                        tmpPwrSeq=flipud(tmpPwrSeq);
                        tmpAxisSeq=flipud(tmpAxisSeq);
                        lean = -lean;
                    end
                    cPathSeq = [cPathSeq; tmpPath];
                    cPwrSeq = [cPwrSeq; tmpPwrSeq];
                    cAxisSeq = [cAxisSeq; tmpAxisSeq];
                end
                if rem(lyrIdx,2)==1
                    cPathSeq=flipud(cPathSeq);
                    cPwrSeq=flipud(cPwrSeq);
                    cAxisSeq=flipud(cAxisSeq);
                    lean = -lean;
                end
                path = [path; cPathSeq, sequentialSolveBC(cAxisSeq, [0,0])];
                pwrSeq = [pwrSeq; cPwrSeq];
            end
        end
    end
end
