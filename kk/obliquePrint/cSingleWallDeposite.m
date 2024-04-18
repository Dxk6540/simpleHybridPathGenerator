classdef cSingleWallDeposite
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
            sideLyr = geoParam.sideLyrNum;
            pwr = procParam.sPrintParam_.pwr;
            
            path = [];
            pwrSeq = [];
            feedOffset = [];
            
%             cRot = atan((stPt(2)-edPt(2))/(stPt(1)-edPt(1)))/pi*180;
            cRot = atan( (stPt(1)-edPt(1)) / (stPt(2)-edPt(2)) )/pi*180;
            if geoParam.inverseC == 1
                cRot = -cRot;
            end
            
            % one side             
            for lyrIdx = 0 : sideLyr - 1
                stPtTmp = [stPt(1),stPt(2)+lyrIdx*thickness, zOff, agl, cRot];
                edPtTmp = [edPt(1),edPt(2)+lyrIdx*thickness, zOff, agl, cRot];
                cPathSeq = [stPtTmp;
                            edPtTmp;
                            stPtTmp];
                cPwrSeq = [0;pwr;0];
                path = [path; cPathSeq];
                pwrSeq = [pwrSeq; cPwrSeq];
            end
            % middle            
            stPtTmp = [stPt, zOff, 0, cRot];
            path = [path; stPtTmp];
            pwrSeq = [pwrSeq; 0];            
            
            % another side                    
            for lyrIdx = 0 : sideLyr - 1
                stPtTmp = [stPt(1),stPt(2)-lyrIdx*thickness, zOff, agl, -cRot];
                edPtTmp = [edPt(1),edPt(2)-lyrIdx*thickness, zOff, agl, -cRot];
                cPathSeq = [stPtTmp;
                            edPtTmp;
                            stPtTmp];
                cPwrSeq = [0;pwr;0];
                path = [path; cPathSeq];
                pwrSeq = [pwrSeq; cPwrSeq];
            end
                        
            % ridge
            for lyrIdx = 0 : lyrNum - 1
                stPtTmp = [stPt, zOff+thickness*lyrIdx, 0, 0];
                edPtTmp = [edPt, zOff+thickness*lyrIdx, 0, 0];
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
            geoParam.inverseC = 0;
            geoParam.sideLyrNum = 3;
%             geoParam.pitchAgl = 25 / 180 * pi;
            
        end                
    end
end
