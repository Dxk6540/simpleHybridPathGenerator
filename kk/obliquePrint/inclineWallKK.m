% date: 20230515
% functions for incline single channel wall
% author: Yuanzhi CHEN

classdef inclineWallKK
	properties
        shape_="Wall";
    end
    
    methods(Static)
        function [path, pwrSeq] = genPrintingPath(geoParam, procParam)
%             wall: (1) is the length along x direction and (2) is the
%             channel number.
            stPt = geoParam.startPt;
            edPt = geoParam.endPt;
            height = geoParam.height; % in WCS
            zOff = geoParam.Zoffset;
            
            tol = geoParam.tol;
            thickness = geoParam.lyrThickness; % in WCS
            agl = geoParam.rollAgl;
            lyrNum = round(height/thickness);
            
            pwr = procParam.sPrintParam_.pwr;
            
            path = [];
            pwrSeq = [];
            feedOffset = [];
            
%             cRot = atan((stPt(2)-edPt(2))/(stPt(1)-edPt(1)))/pi*180;
            cRot = atan( (stPt(1)-edPt(1)) / (stPt(2)-edPt(2)) )/pi*180;

            for lyrIdx = 0 : lyrNum - 1
                stPtTmp = [stPt, zOff+thickness*lyrIdx, agl, cRot];
                edPtTmp = [edPt, zOff+thickness*lyrIdx, agl, cRot];
                cPathSeq = [stPtTmp;
                            edPtTmp;
                            stPtTmp];
                cPwrSeq = [0;pwr;0];
                path = [path; cPathSeq];
                pwrSeq = [pwrSeq; cPwrSeq];
            end
        end
        
        function geoParam = getDefaultParam()
            geoParam.startPt = [0,0];
            geoParam.endPt = [10,10];
            geoParam.height = 20;
            geoParam.Zoffset = 70;

            geoParam.tol = 0.1;
            geoParam.lyrThickness = 0.8; % max rad?
            geoParam.rollAgl = 15 / 180 * pi;
%             geoParam.pitchAgl = 25 / 180 * pi;
            
        end                
    end
end
