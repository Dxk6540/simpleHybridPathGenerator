classdef cubeShell
	properties
        shape_="cubeShell";
    end    
    
    methods
        function geoParam = getDefaultParam(obj)
            geoParam.sideLen = 50;
            geoParam.center = [0,20,0];
            geoParam.lyrNum = 10;
            geoParam.lyrThickness = 0.5;

            geoParam.step = 1;
            geoParam.channel = 2;            
        end
        
        function [path,pwrSeq] = genPrintingPath(obj, geoParam, procParam)
            path = [];
            pwrSeq = [];
            
            pwr = procParam.pwr;
            curZ = 0;
            ctrX = geoParam.center(1);
            ctrY = geoParam.center(2);
            hSideLen = geoParam.sideLen/2;
            cnr1 = [ctrX-hSideLen, ctrY-hSideLen];
            cnr2 = [ctrX-hSideLen, ctrY+hSideLen];
            cnr3 = [ctrX+hSideLen, ctrY+hSideLen];
            cnr4 = [ctrX+hSideLen, ctrY-hSideLen];
            
            for i = 1:geoParam.lyrNum
                curZ = (i-1) * geoParam.lyrThickness;
                path = [path; 
                    cnr1(1),cnr1(2),curZ;
                    cnr2(1),cnr2(2),curZ;
                    cnr3(1),cnr3(2),curZ;
                    cnr4(1),cnr4(2),curZ;
                    cnr1(1),cnr1(2),curZ;];
                pwrSeq = [pwrSeq, pwr,pwr,pwr,pwr,pwr];
            end
            
        end
        
        function path = genMachiningPath(obj, cylinderR, startCenter, tol, wpHeight, lyrThickness, toolRadiu, wallOffset, zOffset, side)
            path = [];
        end        
    end
    

    
end