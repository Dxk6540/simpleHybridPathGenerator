% date: 20230226
% functions for alternative hybrid manufactuing a vase
% author: Yuanzhi CHEN

classdef vase
    methods(Static)
        function [path,pwrSeq] = genPrintingPath(baseRadiu, startCenter, tol, lyrNum, lyrThickness, pwr, zOffset, channel, step)
            % planar circle path
            path = [];
            pwrSeq = [];
            for lyrIdx = 0 : lyrNum - 1    
                tPathSeq = [];
                tPwrSeq = [];
                radius = baseRadiu * vase.genVaseRadius(lyrIdx * lyrThickness);
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
        
        function [cntrPath, toolAxis] = genMachiningPath(baseRadiu, startCenter, tol, wpHeight, lyrThickness, toolRadiu, wallOffset, zOffset, side)

            % roughing circle path   
            if floor(wpHeight/lyrThickness) == wpHeight/lyrThickness
                lyrNum = floor(wpHeight/lyrThickness);            
            else
                lyrNum = floor(wpHeight/lyrThickness) + 1;    
            end
            lyrHeight = wpHeight/lyrNum;

            if zOffset > 0
                lyrNum = lyrNum + 6;
            end


            toolContactPts = [];
            toolAxis = [];
            fcNormal = [];
            for lyrIdx = 1:lyrNum
                z = wpHeight - lyrIdx * lyrHeight + zOffset;
                vaseRadius = baseRadiu * vase.genVaseRadius(z); 
                tanVec2 = vase.getVaseTangent(z);
%                 mtRadiu = vaseRadius + side*(toolRadiu + wallOffset);
                mtRadiu = vaseRadius + side * wallOffset;
                lyrPtNum = floor(2 * mtRadiu * pi / tol)+1;                
                aglStep = 2 * pi / lyrPtNum;                
                for j = 1 : lyrPtNum
                    x = cos(aglStep * j) * mtRadiu + startCenter(1);
                    y = sin(aglStep * j) * mtRadiu + startCenter(2); 
                    toolContactPts = [toolContactPts; x,y,z];
                end
            end
            
            
            
            path = mPathSeq;            
        end
        
        
        function ctrPt = getToolCenterPt(ccPt, toolAxis, fcNormal, toolRadiu)
            mtDir = cross(toolAxis, cross(fcNormal, toolAxis));
            mtDir = mtDir/ norm(mtDir);
            ctrPt = ccPt + mtDir * toolRadiu;            
        end
        
        function vec3d = convertTo3DVec(xzVec2d, agl)
            % xzVec2d is the vec with cord [x, 0, z]
            vec3d = [cos(agl)*xzVec2d(1), sin(agl)*xzVec2d(1), xzVec2d(2)];            
        end
        
        function radius = genVaseRadius(zValue)
            radius = 3.5 * (sin(((((zValue)/(7.5))+46)/(2)))+1.5 * sin(((((zValue)/(7.5))+46)/(4))+45)+2 * cos(((((zValue)/(7.5))+46)/(6)))+7);
        end
        
        function tangent2D = getVaseTangent(zValue)
            delta = 1e-9;
            pe = [vase.genVaseRadius(zValue + delta), zValue + delta];
            p0 = [vase.genVaseRadius(zValue - delta), zValue - delta];
            tangent2D = pe - p0;
            tangent2D = tangent2D/norm(tangent2D);
        end
        
        function normal2D = getVaseNormal(zValue)
            tg = vase.getVaseTangent(zValue);
            normal2D = (rot2(pi/2) * tg')';
        end        
    end
end
