function  [point,on_off,traverse] = pt2dTraverse(point, on_off, traverse)

    % gen traverse path step 
    mvStep = 0.1;
    head=point(1,:);
    tail=point(end,:);
    dist=norm(tail-head);
    if dist>mvStep
        count=floor(dist/mvStep);
        move=(head-tail)/count;
        point=[point;tail+move.*(1:count-1)'];
        on_off=[on_off;zeros(count-1,1)];
        traverse=[traverse;ones(count-1,1)];
    end
%     point_3 = 
end