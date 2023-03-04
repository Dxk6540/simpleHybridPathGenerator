% date: 20230226
% functions for alternative hybrid manufactuing a vase
% author: Yuanzhi CHEN

classdef vase
	properties
        shape_="Vase";
    end
	properties (Constant)
        drawStep_ = 200;
    end
    
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
                radius = vase.genVaseRadius(lyrIdx * lyrThickness + zOffset);
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
            scatter3(path(1:vase.drawStep_:end,1), path(1:vase.drawStep_:end,2), path(1:vase.drawStep_:end,3),2)
            hold on
        end
        
        function pathSeq = genMachiningPath(~, startCenter, tol, wpHeight, lyrThickness, toolRadiu, wallOffset, zOffset, side)
            % roughing circle path   
            if floor(wpHeight/lyrThickness) == wpHeight/lyrThickness
                lyrNum = floor(wpHeight/lyrThickness);            
            else
                lyrNum = floor(wpHeight/lyrThickness) + 1;    
            end
            lyrHeight = wpHeight/lyrNum;
            disp(['total layer ', num2str(lyrNum)])
            
            if zOffset > 5
                lyrNum = lyrNum + 6;
            end
            data = cell(lyrNum, 3);
            rollAgl = pi/6;
            startIdx = 7;
            
            for lyrIdx = startIdx:lyrNum
                toolContactPts = [];
                toolAxes = [];
                fcNormals = [];
                toolCntrPts = [];
                
                disp(['process layer ', num2str(lyrIdx)])
                z = wpHeight - lyrIdx * lyrHeight + zOffset;

                vaseRadius = vase.genVaseRadius(z); 
                tanVec2 = vase.getVaseTangent(z);
                fcNorm2 = vase.getVaseNormal(z, side);
                toolAxis2d = [side * sin(rollAgl),cos(rollAgl)];
                
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
                    cntrPt = vase.getToolCenterPt(ccPt, fcNorm, toolRadiu);
                    if cntrPt(3)-toolRadiu<=tol
                        continue;
                    end
                    
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
            bcSeq = sequentialSolveBC(toolAxisSeq, [0,0]);
            scatter3(toolContactPtSeq(1:vase.drawStep_:end,1), toolContactPtSeq(1:vase.drawStep_:end,2), toolContactPtSeq(1:vase.drawStep_:end,3),2)
            hold on
            scatter3(toolCntrPtSeq(1:vase.drawStep_:end,1), toolCntrPtSeq(1:vase.drawStep_:end,2), toolCntrPtSeq(1:vase.drawStep_:end,3),2)
            hold on
            ax = gca;
            vase.drawTools(ax, toolCntrPtSeq, toolAxisSeq, vase.drawStep_);
            axis equal
            hold on
            pathSeq=[toolCntrPtSeq,bcSeq];
%             filename = 'verycut.txt';
%             fid = fopen(filename, 'a+');
%             for i=1:size(toolContactPtSeq,1)
%                 fprintf(fid, "GOTO/%f, %f, %f, %f, %f, %f\r\n", toolCntrPtSeq(i,1), toolCntrPtSeq(i,2),toolCntrPtSeq(i,3),toolAxisSeq(i,1),toolAxisSeq(i,2),toolAxisSeq(i,3));
%             end
%             fclose(fid);
        end
        
        
        function ctrPt = getToolCenterPt(ccPt, fcNormal, toolRadiu)
            ctrPt = ccPt + fcNormal * toolRadiu;            
        end
        
        function vec3d = convertTo3DVec(xzVec2d, agl)
            % xzVec2d is the vec with cord [x, 0, z]
            vec3d = [cos(agl)*xzVec2d(1), sin(agl)*xzVec2d(1), xzVec2d(2)];            
        end
          
        function radius = genVaseRadius(zValue)
            radius = 3.5 * (sin(((((zValue)/(7.5))+46)/(2)))+1.5 * sin(((((zValue)/(7.5))+46)/(4))+45)+2 * cos(((((zValue)/(7.5))+46)/(6)))+7);
        end
        
        function tangent2D = getVaseTangent(zValue)
            tangent2D = [((1)/(360))* (63 * cos(((1)/(4)) * (((2)/(15)) * zValue+46)+45)+84 * cos(((1)/(2)) * (((2)/(15)) * zValue + 46))- 56 * sin(((1)/(6)) * (((2)/(15)) * zValue+46))),1];
            tangent2D = tangent2D/norm(tangent2D);
        end
        
        function normal2D = getVaseNormal(zValue, side)
            % the normal towards outter surf
            tg = vase.getVaseTangent(zValue);
            normal2D = (rot2(-side * pi/2) * tg')';
        end
        
        function radius = getRadius(zValue)
            radius = 3.5 * (sin(((((zValue)/(7.5))+46)/(2)))+1.5 * sin(((((zValue)/(7.5))+46)/(4))+45)+2 * cos(((((zValue)/(7.5))+46)/(6)))+7);
        end
        
        function drawTools(ax, origPosSeq, toolAxisSeq, step)
            toolLen  = 25;
            for i = 1:step:length(toolAxisSeq)
                p0 = origPosSeq(i,:);
                curAxis = toolAxisSeq(i,:); 
                pe = p0 + toolLen*curAxis;
                plot3(ax, [p0(1), pe(1)], [p0(2), pe(2)], [p0(3), pe(3)])
                hold on    
            end
        end
    end
end
