function [point_3,angle,height]=convert2DPoint(point,center,radius,offset)
    height=offset+point(:,1)-center(1);
    angle=(point(:,2)-center(2))*180/pi/radius;
    point_3=[radius*cos(angle/180*pi),-radius*sin(angle/180*pi),height];
end