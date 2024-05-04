function [point_3,angle,height,on_off,traverse]=convert2DPoint(point,on_off,traverse,center,radius,offset,lyrNum,lyrHeight,remelt)
    head=point(1,:);
    tail=point(end,:);
    dist=norm(tail-head);
    if dist>0.011
        count=floor(dist/0.01);
        move=(head-tail)/count;
        point=[point;tail+move.*(1:count-1)'];
        on_off=[on_off;zeros(count-1,1)];
        traverse=[traverse;ones(count-1,1)];
    end
    angle=(point(:,2)-center(2))*180/pi/radius;
    height=offset+point(:,1)-center(1);
    point_3=[];
    for i=1-remelt:lyrNum
        point_3=[point_3;(radius+max(0,i-1)*lyrHeight)*cos(angle/180*pi),-(radius+max(0,i-1)*lyrHeight)*sin(angle/180*pi),height];
    end
    angle=repmat(angle,lyrNum+remelt,1);
    height=repmat(height,lyrNum+remelt,1);
    on_off=repmat(on_off,lyrNum+remelt,1);
    traverse=repmat(traverse,lyrNum+remelt,1);
    point_3=point_3(1:end-count,:);
    angle=angle(1:end-count,:);
    height=height(1:end-count,:);
    on_off=on_off(1:end-count,:);
    traverse=traverse(1:end-count,:);
end