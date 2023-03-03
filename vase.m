% date: 20230226
% functions for alternative hybrid manufactuing a vase
% author: Yuanzhi CHEN

classdef vase
    methods(Static)
        function [path,pwrSeq] = genPrintingPath(~, startCenter, tol, lyrNum, lyrThickness, pwr, zOffset, channel, step)
            % planar circle path
            path = [];
            pwrSeq = [];
            for lyrIdx = 0 : lyrNum - 1    
                disp(['process printing layer ', num2str(lyrIdx)])                
                tPathSeq = [];
                tPwrSeq = [];
%                 radius = baseRadiu * vase.genVaseRadius(lyrIdx * lyrThickness);
                radius = vase.genVaseRadius(lyrIdx * lyrThickness);
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
%                 data{lyrIdx+1, 1} = tPathSeq;
%                 data{lyrIdx+1, 2} = tPwrSeq;               
            end
            pwrSeq(1) = pwr;
        end
        
        function [toolContactPtSeq, toolCntrPtSeq, toolAxisSeq, fcNormalSeq] = genMachiningPath(~, startCenter, tol, wpHeight, lyrThickness, toolRadiu, wallOffset, zOffset, rollAgl, side)
            % roughing circle path   
            if floor(wpHeight/lyrThickness) == wpHeight/lyrThickness
                lyrNum = floor(wpHeight/lyrThickness);            
            else
                lyrNum = floor(wpHeight/lyrThickness) + 1;    
            end
            lyrHeight = wpHeight/lyrNum;
            disp(['total layer ', num2str(lyrNum)])
            
            if zOffset > 0
                lyrNum = lyrNum + 6;
            end
            data = cell(lyrNum, 4);
            
            for lyrIdx = 1:lyrNum
                toolContactPts = [];
                toolAxes = [];
                fcNormals = [];
                toolCntrPts = [];
                
                disp(['process layer ', num2str(lyrIdx)])
                z = wpHeight - lyrIdx * lyrHeight + zOffset;

                vaseRadius = vase.genVaseRadius(z); 
                tanVec2 = vase.getVaseTangent(z);
                fcNorm2 = vase.getVaseNormal(z);
                toolAxis2d = vase.getToolAxis(tanVec2, -side * rollAgl);
                
%                 mtRadiu = vaseRadius + side*(toolRadiu + wallOffset);
                mtRadiu = vaseRadius + side * wallOffset;
                lyrPtNum = floor(2 * mtRadiu * pi / tol)+1;                
                aglStep = 2 * pi / lyrPtNum;                
                for j = 1 : lyrPtNum
                    x = cos(aglStep * j) * mtRadiu + startCenter(1);
                    y = sin(aglStep * j) * mtRadiu + startCenter(2); 
                    ccPt = [x,y,z];
                    
                    fcNorm = vase.convertTo3DVec(fcNorm2, aglStep * j);
                    tanVec = vase.convertTo3DVec(tanVec2, aglStep * j);     
                    toolAxis = vase.convertTo3DVec(toolAxis2d, aglStep * j);                         
                    cntrPt = vase.getToolCenterPt(ccPt, toolAxis, -fcNorm, side * toolRadiu);
                    
                    toolContactPts = [toolContactPts; ccPt];    
                    toolCntrPts = [toolCntrPts; cntrPt];
                    toolAxes = [toolAxes; toolAxis];
                    fcNormals = [fcNormals; fcNorm];
                end
                data{lyrIdx, 1} = toolContactPts;
                data{lyrIdx, 2} = toolCntrPts;
                data{lyrIdx, 3} = toolAxes;
                data{lyrIdx, 4} = fcNormals;                                
            end 
            toolContactPtSeq = cell2mat(data(:,1));
            toolCntrPtSeq = cell2mat(data(:,2));
            toolAxisSeq = cell2mat(data(:,3));
            fcNormalSeq = cell2mat(data(:,4));
            
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
        
        function toolAxis2d = getToolAxis(tanVec2d, roll)
            % rot the tangent a degree 
            toolAxis2d = (rot2(roll) * tanVec2d')';                        
        end
        
        function radius = genVaseRadius(zValue)
            radius = 3.5 * (sin(((((zValue)/(7.5))+46)/(2)))+1.5 * sin(((((zValue)/(7.5))+46)/(4))+45)+2 * cos(((((zValue)/(7.5))+46)/(6)))+7);
        end
        
        function tangent2D = getVaseTangent(zValue)
            tangent2D = [((1)/(360))* (63 * cos(((1)/(4)) * (((2)/(15)) * zValue+46)+45)+84 * cos(((1)/(2)) * (((2)/(15)) * zValue + 46))- 56 * sin(((1)/(6)) * (((2)/(15)) * zValue+46))),1];
            tangent2D = tangent2D/norm(tangent2D);
        end
        
        function normal2D = getVaseNormal(zValue)
            % the normal towards outter surf
            tg = vase.getVaseTangent(zValue);
            normal2D = (rot2(pi/2) * tg')';
        end        
    end
end
