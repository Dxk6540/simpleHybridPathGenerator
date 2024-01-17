function bcSeq = sequentialSolveBC(ijkSeq, initBC)
% ijk is n*3 array represents the tool axis components on 3 coordinate axes
% bc is n*2 array represents the table rotation angle

    lastBC = initBC;
    bcSeq = zeros(size(ijkSeq,1),2);
    windingNum = 0;
    for i = 1:size(ijkSeq,1)
        toolAixs = ijkSeq(i,:);

        faiB = acos(toolAixs * [0,0,1]');
        if(ijkSeq(i,1) ==0 && ijkSeq(i,2) == 0)
            faiC = 0;
        else
            axisProj = [ijkSeq(i,1), ijkSeq(i,2), 0];
            axisProj = axisProj/ norm(axisProj);        
            faiC = acos(axisProj*[1,0,0]');
            if axisProj(2) < 0
                faiC = 2*pi - faiC;
            end
        end
        solA = [faiB, faiC];
        solB = [-faiB, faiC + pi];
        distA = bcSolDist(lastBC, solA);
        distB = bcSolDist(lastBC, solB);

%         if distA > distB
%             bcSeq(i,:)  = solB;
%         elseif distA == distB
%             solB    
%         else
%             bcSeq(i,:)  = solA;            
%         end
        thres = 1e-4;
        if faiC > lastBC(2) && lastBC(2) < thres && faiC > pi*2 - thres
            windingNum = windingNum - 1;
        end
        if lastBC(2) > faiC && lastBC(2) > pi*2 - thres && faiC < thres
            windingNum = windingNum + 1;
        end
        lastBC = solA;        
        solA(2) = solA(2) + 2 * pi * windingNum;
        bcSeq(i,:)  = solA;  
%         lastBC = bcSeq(i,:);
    end
    
    bcSeq = bcSeq/pi * 180;
%     windingNum = 0;
%     for i = 1:(size(bcSeq,1)-1)
%         curPt = bcSeq(i);
%         nextPt = bcSeq(i+1);
%     end
    
end











function dist = bcSolDist(ptA, ptB)
    dist = acos(sin(ptA(1))*sin(ptB(1)) + cos(ptA(1))*cos(ptB(1))*cos(ptA(2)-ptB(2)));
end


