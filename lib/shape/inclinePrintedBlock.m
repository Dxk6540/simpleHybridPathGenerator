% date: 20230515
% functions for incline single channel wall
% author: Yuanzhi CHEN

classdef inclinePrintedBlock
	properties
        shape_="Wall";
    end
    
    methods(Static)
        function [path, pwrSeq,feedSeq] = genPrintingPath(length, startPoint, lead, lyrNum, lyrThickness, pwr, incline, channel, step, lean, feedrate, traverse, offset)
%             cubeShape: (1) is the length along x direction and (2) is the
%             channel number.
            path = [];
            pwrSeq = [];
            feedSeq = [];
            y=startPoint(2);
            inclineLeanAngle=incline+lean;
            for lyrIdx = 0 : lyrNum - 1
                cPathSeq = [];
                cPwrSeq = [];
                cAxisSeq = [];
                cFeedSeq=[];
                for chnIdx = 0 : channel - 1
                    x=startPoint(1) + chnIdx * step;
                    zValue = lyrThickness * lyrIdx;
                    tmpPath = [];
                    tmpPwrSeq = [];
                    tmpAxisSeq = [];
                    tmpFeedSeq = [];
                    tmpLength = length + zValue*sin(incline/180*pi);
                    tmpPath = [tmpPath; x, startPoint(2)-lead, zValue];
                    tmpPwrSeq = [tmpPwrSeq; 0];
                    tmpAxisSeq = [tmpAxisSeq;(rotx(lean/180*pi)*[0,0,1]')'];
                    tmpFeedSeq = [tmpFeedSeq; traverse];
                    tmpPath = [tmpPath; x, startPoint(2)-0.1, zValue];
                    tmpPwrSeq = [tmpPwrSeq; 0];
                    tmpAxisSeq = [tmpAxisSeq;(rotx(lean/180*pi)*[0,0,1]')'];
                    tmpFeedSeq = [tmpFeedSeq; feedrate];
                    tmpPath = [tmpPath; x, startPoint(2), zValue];
                    tmpPwrSeq = [tmpPwrSeq; pwr];
                    tmpAxisSeq = [tmpAxisSeq;(rotx(lean/180*pi)*[0,0,1]')'];
                    tmpFeedSeq = [tmpFeedSeq; feedrate];
                    tmpPath = [tmpPath; x, startPoint(2) + tmpLength/3, zValue];
                    tmpPwrSeq = [tmpPwrSeq; pwr];
                    tmpAxisSeq = [tmpAxisSeq;(rotx(0/180*pi)*[0,0,1]')'];
                    tmpFeedSeq = [tmpFeedSeq; feedrate];
                    tmpPath = [tmpPath; x, startPoint(2) + 2*tmpLength/3, zValue];
                    tmpPwrSeq = [tmpPwrSeq; pwr];
                    tmpAxisSeq = [tmpAxisSeq;(rotx(0/180*pi)*[0,0,1]')'];
                    tmpFeedSeq = [tmpFeedSeq; feedrate];
                    tmpPath = [tmpPath; x, startPoint(2) + tmpLength, zValue];
                    tmpPwrSeq = [tmpPwrSeq; pwr];
                    tmpAxisSeq = [tmpAxisSeq;(rotx(-lean/180*pi)*[0,0,1]')'];
                    tmpFeedSeq = [tmpFeedSeq; feedrate];
                    tmpPath = [tmpPath; x, startPoint(2) + tmpLength + 1, zValue];
                    tmpPwrSeq = [tmpPwrSeq; 0];
                    tmpAxisSeq = [tmpAxisSeq;(rotx(-inclineLeanAngle/180*pi)*[0,0,1]')'];
                    tmpFeedSeq = [tmpFeedSeq; feedrate];
                    tmpPath = [tmpPath; x, startPoint(2) + tmpLength + lead, zValue];
                    tmpPwrSeq = [tmpPwrSeq; 0];
                    tmpAxisSeq = [tmpAxisSeq;(rotx(-inclineLeanAngle/180*pi)*[0,0,1]')'];
                    tmpFeedSeq = [tmpFeedSeq; traverse];
                    if rem(chnIdx,2)==0
                        tmpPath=flipud(tmpPath);
                        tmpPwrSeq=flipud(tmpPwrSeq);
                        tmpAxisSeq=flipud(tmpAxisSeq);
                        tmpFeedSeq=flipud(tmpFeedSeq);
                    end
                    cPathSeq = [cPathSeq; tmpPath];
                    cPwrSeq = [cPwrSeq; tmpPwrSeq];
                    cAxisSeq = [cAxisSeq; tmpAxisSeq];
                    cFeedSeq = [cFeedSeq; tmpFeedSeq];
                end
                if rem(lyrIdx,2)==1
                    cPathSeq=flipud(cPathSeq);
                    cPwrSeq=flipud(cPwrSeq);
                    cFeedSeq=flipud(cFeedSeq);
                end
                cAxisSeq=flipud(cAxisSeq);
                path = [path; cPathSeq, sequentialSolveBC(cAxisSeq, [0,0])];
                pwrSeq = [pwrSeq; cPwrSeq];
                feedSeq=[feedSeq; cFeedSeq];
            end
        end
    end
end
