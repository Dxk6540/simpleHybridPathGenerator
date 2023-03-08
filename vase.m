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
        function [path,pwrSeq,feedrateOffset] = genPrintingPath(~, startCenter, tol, lyrNum, lyrThickness, pwr, zOffset, channel, step)
            % planar circle path
            path = cell(lyrNum);
            pwrSeq = cell(lyrNum);
            feedrateOffset = cell(lyrNum);
            for lyrIdx = 0 : lyrNum - 1    
                disp(['process printing layer ', num2str(lyrIdx)])                
                radius = vase.genVaseRadius(lyrIdx * lyrThickness + zOffset);
                lyrPtNum = floor(2 * radius * pi / tol)+1;
                aglStep = 2 * pi / lyrPtNum;
                tPathSeq = ones(channel * lyrPtNum,3);
                tPwrSeq = ones(channel * lyrPtNum,1);
                tOffsetSeq = ones(channel * lyrPtNum,1);
                if channel > 1
                    for chnIdx = 0 : channel - 1
                        for ptIdx = 0 : lyrPtNum - 1
                            x = cos(aglStep * ptIdx) * (radius - chnIdx * step) + startCenter(1);
                            y = sin(aglStep * ptIdx) * (radius - chnIdx * step) + startCenter(2);
                            z = lyrIdx * lyrThickness + zOffset;
                            speedOffset = (1.05-abs(aglStep * ptIdx-0.65*pi)/pi*0.1);
                            tPathSeq(ptIdx+chnIdx*lyrPtNum+1,:) = [x,y,z];
                            tPwrSeq(ptIdx+chnIdx*lyrPtNum+1) = pwr;
                            tOffsetSeq(ptIdx+chnIdx*lyrPtNum+1) = speedOffset;
                        end
                        tPwrSeq(1)= 0;
                        tPwrSeq(end) = 0;                
                    end
                else
                   for ptIdx = 0 : lyrPtNum - 1
                        x = cos(aglStep * ptIdx) * radius + startCenter(1);
                        y = sin(aglStep * ptIdx) * radius + startCenter(2);
                        z = lyrIdx * lyrThickness + zOffset + ptIdx * lyrThickness / lyrPtNum;
                        speedOffset = (1.05-abs(aglStep * ptIdx-0.65*pi)/pi*0.1);
                        tPathSeq(ptIdx+1,:) = [tPathSeq; x,y,z];
                        tPwrSeq(ptIdx+1) = pwr;
                        tOffsetSeq(ptIdx+1) = speedOffset;
                   end
                   tPwrSeq(1)= 0;
                   tPwrSeq(end) = 0; 
                end
                % stop the power when lift the tool 
                path{lyrIdx+1} = tPathSeq;
                pwrSeq{lyrIdx+1} = tPwrSeq;
                feedrateOffset{lyrIdx+1} = tOffsetSeq;
            end
            path = cell2mat(path);
            pwrSeq = cell2mat(pwrSeq);
            feedrateOffset = cell2mat(feedrateOffset);
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
            startIdx = 0;
            if zOffset > 5
                lyrNum = lyrNum + startIdx;
            end
            rollAgl = 10 / 180 * pi;
            count = lyrNum - startIdx + 1;
            pathSeq = cell(count,1);
            toolContactPtSeq = cell(count,1);
            toolTipPtSeq = cell(count,1);
            toolAxisSeq = cell(count,1);
            fcNormalSeq = cell(count,1);
            
            % walloffset machining's tool quit path
            quitPath = [];
            for lyrIdx = startIdx:lyrNum
                z = wpHeight - lyrIdx * lyrHeight + zOffset;
                vaseRadius = vase.genVaseRadius(z); 
                fcNorm2 = vase.getVaseNormal(z, side);
                toolAxis2d = [side * sin(rollAgl),cos(rollAgl)];
                mtRadiu = vaseRadius + side * wallOffset;                            
                x = cos(0) * mtRadiu + startCenter(1);
                y = sin(0) * mtRadiu + startCenter(2); 
                ccPt = [x,y,z];

                fcNorm = vase.convertTo3DVec(fcNorm2, 0);    
                toolAxis = vase.convertTo3DVec(toolAxis2d, 0);                         
                ttPt = vase.getToolCenterPt(ccPt, fcNorm, toolAxis, toolRadiu);
                toolCenterPt = ccPt + fcNorm * toolRadiu;
                if toolCenterPt(3) - toolRadiu <= 2
                    continue;
                end
                quitPath=[quitPath; ttPt + 10 * side * tol, sequentialSolveBC(toolAxis, [0,0])];
            end
            
            for lyrIdx = lyrNum:-1:startIdx
                disp(['process layer ', num2str(lyrIdx)])
                z = wpHeight - lyrIdx * lyrHeight + zOffset;

                vaseRadius = vase.genVaseRadius(z); 
                fcNorm2 = vase.getVaseNormal(z, side);
                toolAxis2d = [side * sin(rollAgl),cos(rollAgl)];
                
                mtRadiu = vaseRadius + side * wallOffset;
                lyrPtNum = floor(2 * mtRadiu * pi / tol)+1;                
                aglStep = 2 * pi / lyrPtNum;
                tToolContactPts = [];
                tToolTipPts = [];
                tToolAxes = [];
                tFaceNprmals = [];
                for j = 0 : lyrPtNum
                    x = cos(aglStep * j) * mtRadiu + startCenter(1);
                    y = sin(aglStep * j) * mtRadiu + startCenter(2); 
                    ccPt = [x,y,z];
                    
                    fcNorm = vase.convertTo3DVec(fcNorm2, aglStep * j);     
                    toolAxis = vase.convertTo3DVec(toolAxis2d, aglStep * j);                         
                    ttPt = vase.getToolCenterPt(ccPt, fcNorm, toolAxis, toolRadiu);
                    toolCenterPt = ccPt + fcNorm * toolRadiu;
                    if toolCenterPt(3) - toolRadiu <= 2
                        break;
                    end
                    
                    tToolContactPts = [tToolContactPts; ccPt];    
                    tToolTipPts = [tToolTipPts; ttPt];
                    tToolAxes = [tToolAxes; toolAxis];
                    tFaceNprmals = [tFaceNprmals; fcNorm];
                end
                if toolCenterPt(3) - toolRadiu > 2
                	tToolContactPts = [tToolContactPts; ccPt];    
                    tToolTipPts = [tToolTipPts; ttPt + [10 * side * tol,0,0]];
                    tToolAxes = [tToolAxes; toolAxis];
                    tFaceNprmals = [tFaceNprmals; fcNorm];
                end
            	toolContactPtSeq{lyrNum - lyrIdx + 1} = tToolContactPts;
                toolTipPtSeq{lyrNum - lyrIdx + 1} = tToolTipPts;
                toolAxisSeq{lyrNum - lyrIdx + 1} = tToolAxes;
                fcNormalSeq{lyrNum - lyrIdx + 1} = tFaceNprmals;
            end 
            bcSeq = sequentialSolveBC(cell2mat(toolAxisSeq), [0,0]);
            pathSeq=[quitPath; cell2mat(toolTipPtSeq),bcSeq];
            
%             scatter3(toolContactPtSeq(1:vase.drawStep_:end,1), toolContactPtSeq(1:vase.drawStep_:end,2), toolContactPtSeq(1:vase.drawStep_:end,3),2)
%             hold on
%             scatter3(toolTipPtSeq(1:vase.drawStep_:end,1), toolTipPtSeq(1:vase.drawStep_:end,2), toolTipPtSeq(1:vase.drawStep_:end,3),2)
%             hold on
%             ax = gca;
%             vase.drawTools(ax, toolTipPtSeq, toolAxisSeq, vase.drawStep_);
%             axis equal
%             hold on

%             filename = 'verycut.txt';
%             fid = fopen(filename, 'a+');
%             for i=1:size(toolContactPtSeq,1)
%                 fprintf(fid, "GOTO/%f, %f, %f, %f, %f, %f\r\n", toolCntrPtSeq(i,1), toolCntrPtSeq(i,2),toolCntrPtSeq(i,3),toolAxisSeq(i,1),toolAxisSeq(i,2),toolAxisSeq(i,3));
%             end
%             fclose(fid);
        end
        
        
        function ctrPt = getToolCenterPt(ccPt, fcNormal, toolAxis, toolRadiu)
            ctrPt = ccPt + fcNormal * toolRadiu - toolAxis * toolRadiu;            
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
