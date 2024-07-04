function [curLyrPt,ori_3,height]=convert2DPoint(point,center,radius,offset, lyrHeight, curIdx)
    angle=(point(:,2)+center(2))*180/pi/radius;
    height=offset+point(:,1)+center(1);
    curRadius = radius+max(0,curIdx-1)*lyrHeight;
    curLyrPt = [curRadius*cos(angle/180*pi),-curRadius*sin(angle/180*pi),height];
    i = cos(angle/180*pi);
    j = -sin(angle/180*pi);
    k = zeros(length(angle),1);
    ori_3 = [i,j,k];    
end