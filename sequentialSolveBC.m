function bcSeq = sequentialSolveBC(ijkSeq, initBC)
% ijk is n*3 array represents the tool axis components on 3 coordinate axes
% bc is n*2 array represents the table rotation angle

    lastBC = initBC;
    bcSeq = zeros(size(ijkSeq,1),2);
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
        bcSeq(i,:)  = solA;  
        lastBC = bcSeq(i,:);
    end
    
    bcSeq = bcSeq/pi * 180;
end











function dist = bcSolDist(ptA, ptB)
    dist = acos(sin(ptA(1))*sin(ptB(1)) + cos(ptA(1))*cos(ptB(1))*cos(ptA(2)-ptB(2)));
end


