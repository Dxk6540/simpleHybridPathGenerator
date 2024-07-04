function [curLyrPt,ori_3]=cylinderCord2CartesianCord(agl, height, curRadius)
    angle=agl;
%     height=offset+point(:,1)+center(1);
%     curRadius = radius+max(0,curIdx-1)*lyrHeight;
    curLyrPt = [curRadius*cos(angle/180*pi),-curRadius*sin(angle/180*pi),height];
    i = cos(angle/180*pi);
    j = -sin(angle/180*pi);
    k = zeros(length(angle),1);
    ori_3 = [i,j,k];    
end