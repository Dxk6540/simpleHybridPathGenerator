% date: 20230515
% functions for incline single channel wall
% author: Yuanzhi CHEN

classdef inclinePrintedBeam
	properties
        shape_="Wall";
    end
    
    methods(Static)
        function [path, pwrSeq, feedSeq] = genPrintingPath(length, startPoint, lead, lyrNum, lyrThickness, pwr, incline, channel, step, dir, lean, feedrate, closure,traverse, offset)
%             cubeShape: (1) is the length along x direction and (2) is the
%             channel number.
            path = [];
            pwrSeq = [];
            feedSeq = [];
            y=startPoint(2);
            lean=-lean;
            for lyrIdx = 0 : lyrNum - 1
                cPathSeq = [];
                cPwrSeq = [];
                cAxisSeq = [];
                cFeedSeq=[];
                if closure && lyrIdx+11>=lyrNum
                    incline=max(15,incline*0.7);
                end
                for chnIdx = 0 : channel - 1 
                    x=startPoint(1) + lyrThickness * lyrIdx * dir;
                    zValue = startPoint(3) + chnIdx * step;
                    tmpPath = [];
                    tmpPwrSeq = [];
                    tmpAxisSeq = [];
                    tmpFeedSeq = [];
                    tmpPath = [tmpPath; x, startPoint(2)-lead, zValue];
                    tmpPwrSeq = [tmpPwrSeq; 0];
                    tmpAxisSeq = [tmpAxisSeq;(roty(incline/180*pi)*rotx(lean/180*pi)*[0,0,1]')'];
                    tmpFeedSeq = [tmpFeedSeq; traverse];
                    tmpPath = [tmpPath; x, startPoint(2)-0.1, zValue];
                    tmpPwrSeq = [tmpPwrSeq; 0];
                    tmpAxisSeq = [tmpAxisSeq;(roty(incline/180*pi)*rotx(lean/180*pi)*[0,0,1]')'];
                    if closure
                        tmpFeedSeq = [tmpFeedSeq; feedrate];
                    else
                        tmpFeedSeq = [tmpFeedSeq; feedrate*offset];
                    end
                    tmpPath = [tmpPath; x, startPoint(2), zValue];
                    tmpPwrSeq = [tmpPwrSeq; pwr];
                    tmpAxisSeq = [tmpAxisSeq;(roty(incline/180*pi)*rotx(lean/180*pi)*[0,0,1]')'];
                    if closure
                        tmpFeedSeq = [tmpFeedSeq; feedrate];
                    else
                        tmpFeedSeq = [tmpFeedSeq; feedrate*offset];
                    end
                    tmpPath = [tmpPath; x, startPoint(2) + length/3, zValue];
                    tmpPwrSeq = [tmpPwrSeq; pwr];
                    tmpAxisSeq = [tmpAxisSeq;(roty(incline/180*pi)*rotx(0/180*pi)*[0,0,1]')'];
                    tmpFeedSeq = [tmpFeedSeq; 1.0*feedrate];
                    tmpPath = [tmpPath; x, startPoint(2) + 2*length/3, zValue];
                    tmpPwrSeq = [tmpPwrSeq; pwr];
                    tmpAxisSeq = [tmpAxisSeq;(roty(incline/180*pi)*rotx(0/180*pi)*[0,0,1]')'];
                    tmpFeedSeq = [tmpFeedSeq; 1.0*feedrate];
                    tmpPath = [tmpPath; x, startPoint(2) + length, zValue];
                    tmpPwrSeq = [tmpPwrSeq; pwr];
                    tmpAxisSeq = [tmpAxisSeq;(roty(incline/180*pi)*rotx(-lean/180*pi)*[0,0,1]')'];
                    tmpFeedSeq = [tmpFeedSeq; feedrate];
                    tmpPath = [tmpPath; x, startPoint(2) + length + 0.1, zValue];
                    tmpPwrSeq = [tmpPwrSeq; 0];
                    tmpAxisSeq = [tmpAxisSeq;(roty(incline/180*pi)*rotx(-lean/180*pi)*[0,0,1]')'];
                    tmpFeedSeq = [tmpFeedSeq; feedrate];
                    tmpPath = [tmpPath; x, startPoint(2) + length + lead, zValue];
                    tmpPwrSeq = [tmpPwrSeq; 0];
                    tmpAxisSeq = [tmpAxisSeq;(roty(incline/180*pi)*rotx(-lean/180*pi)*[0,0,1]')'];
                    tmpFeedSeq = [tmpFeedSeq; traverse];
                    lean = -lean;
                    if rem(chnIdx,2)==0
                        tmpPath=flipud(tmpPath);
                        tmpPwrSeq=flipud(tmpPwrSeq);
                        tmpFeedSeq=flipud(tmpFeedSeq);
                    end
                    tmpAxisSeq=flipud(tmpAxisSeq);
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
