function [path,on_off,traverse]=connectPath(dxf,seq,reverse,group)
    num=length(seq);
    lead=3;
    theta=120/180*pi;
    path=[];
    on_off=[];
    traverse=[];
    for i=1:num
        if reverse(i)==1
            initPath=flipud(dxf.entities(seq(i)).vertex);
        else
            initPath=dxf.entities(seq(i)).vertex;
        end
        tmpPath=[];
        for j=1:size(initPath,1)-1
            if norm(initPath(j+1,:)-initPath(j,:))>0.00001
                tmpPath=[tmpPath;initPath(j,:)];
            end
        end
        initPath=[tmpPath;initPath(end,:)];
        if size(initPath,1)~=1
            % lead in
            if i==1 || group(i)~=group(i-1)
                move=(initPath(1,:)-initPath(2,:))/norm(initPath(1,:)-initPath(2,:));
                if ~strcmp(dxf.entities(seq(i)).name,'CIRCLE') && ~strcmp(dxf.entities(seq(i)).name,'ARC')
                    path=[path;initPath(1,:)+lead*move;initPath(1,:)+0.51*move;initPath(1,:)+0.5*move];
                    on_off=[on_off;0;0;1];
                    traverse=[traverse;0;0;0];
                else
                    path=[path;initPath(1,:)+lead*move;initPath(1,:)+0.01*move];
                    on_off=[on_off;0;0];
                    traverse=[traverse;0;0];
                end
            end

            for j=1:size(initPath,1)-1
                % fishtail
                if on_off(end)==1
                    p0=path(end,:);
                    p1=initPath(j,:);
                    p2=initPath(j+1,:);
                    d1=(p0-p1)/norm(p0-p1);d2=(p2-p1)/norm(p2-p1);
                    if acos(sum(d1.*d2)) < theta
                        path=[path;path(end,:)-0.01*d1;path(end,:)-lead*d1;path(end,:)-lead*d2;path(end,:)-0.01*d2];
                        on_off=[on_off;0;0;0;0];
                        traverse=[traverse;1;1;1;1];
                    end
                end
                % print path
                path=[path;initPath(j,:)];
                on_off=[on_off;1];
                traverse=[traverse;0];
                dist=norm(initPath(j+1,:)-initPath(j,:));
                if dist>0.011
                    count=floor(dist/0.01);
                    move=(initPath(j+1,:)-initPath(j,:))/count;
                    path=[path;initPath(j,:)+move.*(1:count-1)'];
                    on_off=[on_off;ones(count-1,1)];
                    traverse=[traverse;zeros(count-1,1)];
                end
            end
            %lead out
            if i==num || group(i)~=group(i+1)
                if ~strcmp(dxf.entities(seq(i)).name,'CIRCLE') && ~strcmp(dxf.entities(seq(i)).name,'ARC')
                    move=(initPath(end,:)-initPath(end-1,:))/norm(initPath(end,:)-initPath(end-1,:));
                    path=[path;initPath(end,:);initPath(end,:)+0.5*move;initPath(end,:)+0.51*move;initPath(end,:)+lead*move];
                    on_off=[on_off;1;1;0;0];
                    traverse=[traverse;0;0;0;0];                    
                else
                    move=(initPath(end,:)-initPath(end-1,:))/norm(initPath(end,:)-initPath(end-1,:));
                    path=[path;initPath(end,:);initPath(end,:)+0.01*move;initPath(end,:)+lead*move];
                    on_off=[on_off;1;0;0];
                    traverse=[traverse;0;0;0];
                end
            end
        else
            % only one point
            path=[path;initPath(end,:)];
            on_off(end-2:end,:)=[1;1;1];
            traverse(end-2:end,:)=[0;0;0];
            on_off=[on_off;1];
            traverse=[traverse;0];
        end
        % air-move
        if i~=num && group(i)~=group(i+1)
            head=path(end,:);
            if reverse(i+1)==1
                tail=dxf.entities(seq(i+1)).vertex(end,:);
            else
                tail=dxf.entities(seq(i+1)).vertex(1,:);
            end
            dist=norm(tail-head);
            if dist>0.011
                count=floor(dist/0.01);
                move=(tail-head)/count;
                path=[path;head+move.*(1:count-1)'];
                on_off=[on_off;zeros(count-1,1)];
                traverse=[traverse;ones(count-1,1)];
            end
        end
    end
end