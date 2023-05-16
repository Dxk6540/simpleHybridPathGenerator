classdef bendTube
	properties
        shape_="bendTube";
    end    
    
    methods
        function geoParam = getDefaultParam(obj)
            geoParam.guideRadiu = 50;
            geoParam.profileRadiu = 20;
            geoParam.center = [0,20,0];
            geoParam.bendDir = [1,0,0];            
            geoParam.guideDstAgl = 90;

            geoParam.tol = 0.3;
            geoParam.lyrThickness = 0.8; % max rad?
            geoParam.step = 1;
            geoParam.channel = 2;
            
        end
        
        function [path,axisSeq,pwrSeq,feedrateSeq] = genPrintingPath(obj, geoParam, procParam, feedrate)
            % bend tube - circle path
            lyrPtNum = floor(2 * geoParam.profileRadiu * pi / geoParam.tol)+1;
            aglStep = 2 * pi / lyrPtNum; 
            lyrNum = floor((geoParam.guideDstAgl/180) * pi * (geoParam.guideRadiu + geoParam.profileRadiu) / geoParam.lyrThickness);
            lyrAglStep = (geoParam.guideDstAgl/180)*pi/lyrNum;
            maxThickness = (geoParam.guideRadiu + geoParam.profileRadiu) * lyrAglStep;
            minThickness = (geoParam.guideRadiu - geoParam.profileRadiu) * lyrAglStep;
            
            fprintf('maxThickness is %f and min thickness is %f \n', maxThickness, minThickness);
            
            zDir = [0 0 1];
            xDir = geoParam.bendDir / norm(geoParam.bendDir);
            yDir = cross(zDir, xDir);
            yDir = yDir/norm(yDir);
            baseCsR = [xDir', yDir', zDir'];
            baseCsTransl = geoParam.center;
            
            guideCircleCenter = baseCsTransl + geoParam.guideRadiu * xDir;
            rodriguesMat = [0 -yDir(3) yDir(2);yDir(3) 0 -yDir(1); -yDir(2) yDir(1) 0];
            getNewTransl = @(agl) guideCircleCenter + ...
                (-xDir) * geoParam.guideRadiu * (eye(3) + sin(agl)*rodriguesMat+(1-cos(agl))*rodriguesMat*rodriguesMat)';
            
            power = 1;           
            path = [];
            pwrSeq = [];
            axisSeq = [];
            feedrateSeq = [];
            nominalCurCsR = baseCsR * roty(lyrAglStep/pi*180);
            nominalCurCsTransl = getNewTransl(lyrAglStep);
            for lyrIdx = 0 : lyrNum - 1    
                tPathSeq = [];
                tPwrSeq = [];
                lyrAgl = lyrAglStep * lyrIdx;
                curCsR = baseCsR * roty(lyrAgl/pi*180);
                curCsTransl = getNewTransl(lyrAgl);
                if geoParam.channel > 1
                    for chnIdx = 0 : geoParam.channel - 1
                        for j = 0 : lyrPtNum - 1
                            x = cos(pi + aglStep * j) * (geoParam.profileRadiu - chnIdx * geoParam.step);
                            y = sin(pi + aglStep * j) * (geoParam.profileRadiu - chnIdx * geoParam.step);
                            speedOffset = 1-0.025*sin(aglStep*j-0.75*pi);
                            tPathSeq = [tPathSeq; x,y,0];
                            nominalPath=[x,y,0]*nominalCurCsR' + nominalCurCsTransl;
                            tPwrSeq = [tPwrSeq; procParam.pwr];
                            feedrateSeq = [feedrateSeq;speedOffset*nthroot(nominalPath(3)/360,-power)];
                        end
                        tPwrSeq(1)= 0;
                        tPwrSeq(end) = 0;                
                    end
                else
                   for j = 0 : lyrPtNum - 1
                        x = cos(pi + aglStep * j) * (geoParam.profileRadiu - chnIdx * geoParam.step);
                        y = sin(pi + aglStep * j) * (geoParam.profileRadiu - chnIdx * geoParam.step);             
                        tPathSeq = [tPathSeq; x,y,0];
                        tPwrSeq = [tPwrSeq; procParam.pwr];
                    end
                end
                % stop the power when lift the tool 
                toolAxis = curCsR(:,3)';
                tPathSeq =tPathSeq*curCsR' + repmat(curCsTransl,length(tPathSeq),1);
                tNozzleAxisSeq = repmat(toolAxis,length(tPathSeq),1);
                path = [path;tPathSeq];
                axisSeq = [axisSeq; tNozzleAxisSeq];
                pwrSeq = [pwrSeq;tPwrSeq];
            end
            
        end
        
        function path = genMachiningPath(obj, cylinderR, startCenter, tol, wpHeight, lyrThickness, toolRadiu, wallOffset, zOffset, side)
            path = [];
        end        
    end
    

    
end