function [curLyrPt,ori_3,height]=convert2DPoint(point,center,radius,offset, lyrHeight, curIdx)

    angle=(point(:,2)+center(2))*180/pi/radius;
    height=offset+point(:,1)+center(1);
%     point_3=[];
%     for i=1-remelt:lyrNum
%         point_3=[point_3;(radius+max(0,i-1)*lyrHeight)*cos(angle/180*pi),-(radius+max(0,i-1)*lyrHeight)*sin(angle/180*pi),height];
%     end
    curRadius = radius+max(0,curIdx-1)*lyrHeight;
    curLyrPt = [curRadius*cos(angle/180*pi),-curRadius*sin(angle/180*pi),height];
%     angle=repmat(angle,lyrNum+remelt,1);
%     height=repmat(height,lyrNum+remelt,1);
%     on_off=repmat(on_off,lyrNum+remelt,1);
%     traverse=repmat(traverse,lyrNum+remelt,1);
%     if preheat == 0
%         point_3=point_3(1:end-count,:);
%         angle=angle(1:end-count,:);
%         height=height(1:end-count,:);
%         on_off=on_off(1:end-count,:);
%         traverse=traverse(1:end-count,:);
%     end
    i = cos(angle/180*pi);
    j = -sin(angle/180*pi);
    k = zeros(length(angle),1);
    ori_3 = [i,j,k];    
end