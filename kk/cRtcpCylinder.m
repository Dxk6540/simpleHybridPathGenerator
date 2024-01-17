% date: 20240116
% RTCP print Cylinder
% author: Xiaoke DENG



classdef cRtcpCylinder < handle
	properties
        shape_="cRtcpCylinder";
        radius_ = 20;
    end
	properties (Constant)
        drawStep_ = 200;
    end
    
    methods

        function radius = getRadius(obj, zValue)
            %radius = 3.5 * (sin(((((zValue)/(7.5))+46)/(2)))+1.5 * sin(((((zValue)/(7.5))+46)/(4))+45)+2 * cos(((((zValue)/(7.5))+46)/(6)))+7);
            radius = obj.radius_;
        end        
%         function pathSeq = genMachiningPath(~, startCenter, tol, wpHeight, lyrThickness, toolRadiu, wallOffset, zOffset, side, startIdx)
        function pathSeq = genMachiningPath(obj, geoParam, procParam, wallOffset, side, startIdx)
            startCenter = [geoParam.center(1), geoParam.center(2)];
            tol = geoParam.tol;
            wpHeight = geoParam.height;
            obj.radius_ = geoParam.profileRadiu;
            lyrThickness = geoParam.lyrThickness;
            toolRadiu = procParam.sMachinParam_.toolRadiu;
            zOffset = geoParam.center(3);

            % roughing circle path   
            if floor(wpHeight/lyrThickness) == wpHeight/lyrThickness
                lyrNum = floor(wpHeight/lyrThickness);            
            else
                lyrNum = floor(wpHeight/lyrThickness) + 1;    
            end
            lyrHeight = wpHeight/lyrNum;
            disp(['total layer ', num2str(lyrNum)])
            if zOffset > 5
                lyrNum = lyrNum + startIdx;
            end
            rollAgl = geoParam.rollAgl;
            count = lyrNum - startIdx + 1;
            pathSeq = cell(count,1);
            toolContactPtSeq = cell(count,1);
            toolTipPtSeq = cell(count,1);
            toolAxisSeq = cell(count,1);
            fcNormalSeq = cell(count,1);
            
            % walloffset machining's tool quit path
            quitPath = [];
            for lyrIdx = lyrNum:-1:1
                z = wpHeight - lyrIdx * lyrHeight + zOffset;
                radius = obj.getRadius(z); 
                fcNorm2 = cRtcpCylinder.getNormal(z, side);
                toolAxis2d = [side * sin(rollAgl), cos(rollAgl)];
                mtRadiu = radius + side * wallOffset;                            
                x = cos(0) * mtRadiu + startCenter(1);
                y = sin(0) * mtRadiu + startCenter(2); 
                ccPt = [x,y,z];

                fcNorm = cRtcpCylinder.convertTo3DVec(fcNorm2, 0);    
                toolAxis = cRtcpCylinder.convertTo3DVec(toolAxis2d, 0);                         
                ttPt = cRtcpCylinder.getToolCenterPt(ccPt, fcNorm, toolAxis, toolRadiu);
                toolCenterPt = ccPt + fcNorm * toolRadiu;
                if toolCenterPt(3) - toolRadiu <= 2
                    continue;
                end
                quitPath=[quitPath; ttPt + 20 * side * tol, sequentialSolveBC(toolAxis, [0,0])];
            end
            
            for lyrIdx = lyrNum:-1:startIdx
                disp(['process layer ', num2str(lyrIdx)])
                z = wpHeight - lyrIdx * lyrHeight + zOffset;

                radius = obj.getRadius(z); 
                fcNorm2 = cRtcpCylinder.getNormal(z, side);
                toolAxis2d = [side * sin(rollAgl),cos(rollAgl)];
                
                mtRadiu = radius + side * wallOffset;
                lyrPtNum = floor(2 * mtRadiu * pi / tol)+1;                
                aglStep = 2 * pi / lyrPtNum;
                tToolContactPts = [];
                tToolTipPts = [];
                tToolAxes = [];
                tFaceNormals = [];
                for j = 0 : lyrPtNum
                    x = cos(aglStep * j) * mtRadiu + startCenter(1);
                    y = sin(aglStep * j) * mtRadiu + startCenter(2); 
                    ccPt = [x,y,z];
                    
                    fcNorm = cRtcpCylinder.convertTo3DVec(fcNorm2, aglStep * j);     
                    toolAxis = cRtcpCylinder.convertTo3DVec(toolAxis2d, aglStep * j);                         
                    ttPt = cRtcpCylinder.getToolCenterPt(ccPt, fcNorm, toolAxis, toolRadiu);
                    toolCenterPt = ccPt + fcNorm * toolRadiu;
                    if toolCenterPt(3) - toolRadiu <= 2
                        break;
                    end
                    
                    tToolContactPts = [tToolContactPts; ccPt];    
                    tToolTipPts = [tToolTipPts; ttPt];
                    tToolAxes = [tToolAxes; toolAxis];
                    tFaceNormals = [tFaceNormals; fcNorm];
                end
                if toolCenterPt(3) - toolRadiu > 2
                	tToolContactPts = [tToolContactPts; ccPt];    
                    tToolTipPts = [tToolTipPts; ttPt + [10 * side * tol,0,0]];
                    tToolAxes = [tToolAxes; toolAxis];
                    tFaceNormals = [tFaceNormals; fcNorm];
                end
            	toolContactPtSeq{lyrNum - lyrIdx + 1} = tToolContactPts;
                toolTipPtSeq{lyrNum - lyrIdx + 1} = tToolTipPts;
                toolAxisSeq{lyrNum - lyrIdx + 1} = tToolAxes;
                fcNormalSeq{lyrNum - lyrIdx + 1} = tFaceNormals;
            end 
            
            toolAxisSeqMat = flipud(cell2mat(toolAxisSeq));
            toolTipPtSeqMat = flipud(cell2mat(toolTipPtSeq));
            toolContactPtSeqMat = flipud(cell2mat(toolContactPtSeq));
            bcSeq = sequentialSolveBC(toolAxisSeqMat, [0,0]);
            pathSeq=[toolTipPtSeqMat, bcSeq; quitPath];
            
            drawStep_ = 1;
            plot3(toolContactPtSeqMat(1:drawStep_:end,1), toolContactPtSeqMat(1:drawStep_:end,2), toolContactPtSeqMat(1:drawStep_:end,3), 'b')
            hold on
            plot3(toolContactPtSeqMat(1,1), toolContactPtSeqMat(1,2), toolContactPtSeqMat(1,3),'bo')            
%             figure()
            plot3(toolTipPtSeqMat(1:drawStep_:end,1), toolTipPtSeqMat(1:drawStep_:end,2), toolTipPtSeqMat(1:drawStep_:end,3),'r')
            hold on
            plot3(toolTipPtSeqMat(1,1), toolTipPtSeqMat(1,2), toolTipPtSeqMat(1,3),'bo')            
            hold on 
            plot3(quitPath(1:drawStep_:end,1), quitPath(1:drawStep_:end,2), quitPath(1:drawStep_:end,3),'y')
            plot3(quitPath(1,1), quitPath(1,2), quitPath(1,3),'yo')            
            
            ax = gca;
            cRtcpCylinder.drawTools(ax, toolTipPtSeqMat, toolAxisSeqMat, cRtcpCylinder.drawStep_);
            axis equal
            hold on

        end
    end
    
    methods (Static)        
        function geoParam = getDefaultParam(obj)
            geoParam.profileRadiu = 20;
            geoParam.height = 20;
            geoParam.center = [0,20,0];

            geoParam.tol = 0.1;
            geoParam.lyrThickness = 0.8; % max rad?
            geoParam.step = 0.96;
            geoParam.channel = 5;      
            geoParam.rollAgl = 25 / 180 * pi;
        end        
        
        function ctrPt = getToolCenterPt(ccPt, fcNormal, toolAxis, toolRadiu)
            ctrPt = ccPt + fcNormal * toolRadiu - toolAxis * toolRadiu;            
        end
        
        function vec3d = convertTo3DVec(xzVec2d, agl)
            % xzVec2d is the vec with cord [x, 0, z]
            vec3d = [cos(agl)*xzVec2d(1), sin(agl)*xzVec2d(1), xzVec2d(2)];            
        end
                  
        function tangent2D = getTangent(zValue)
            %tangent2D = [((1)/(360))* (63 * cos(((1)/(4)) * (((2)/(15)) * zValue+46)+45)+84 * cos(((1)/(2)) * (((2)/(15)) * zValue + 46))- 56 * sin(((1)/(6)) * (((2)/(15)) * zValue+46))),1];
            tangent2D = [0,1];
            tangent2D = tangent2D/norm(tangent2D);
        end
        
        function normal2D = getNormal(zValue, side)
            % the normal towards outter surf
            tg = cRtcpCylinder.getTangent(zValue);
            normal2D = (rot2(-side * pi/2) * tg')';
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

function mat = rot2(theta)
    mat = [cos(theta), -sin(theta);
          sin(theta), cos(theta)];
end


