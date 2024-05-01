function [path,on_off,traverse]=connectPath(dxf,seq,reverse,group)
    num=length(seq);
    lead=3;
    acute=110;
    path=[];
    on_off=[];
    traverse=[];
    for i=1:num
        if reverse(i)==1
            initPath=flipud(dxf.entities(seq(i)).vertex);
        else
            initPath=dxf.entities(seq(i)).vertex;
        end
        if size(initPath,1)~=1
            % lead in
            if i==1 || group(i)~=group(i-1)
                move=(initPath(1,:)-initPath(2,:))/norm(initPath(1,:)-initPath(2,:));
                path=[path;initPath(1,:)+lead*move;initPath(1,:)+0.01*move];
                on_off=[on_off;0;0];
                traverse=[traverse;0;0];
            end
            % print path
            for j=1:size(initPath,1)-1
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
                move=(initPath(end,:)-initPath(end-1,:))/norm(initPath(end,:)-initPath(end-1,:));
                path=[path;initPath(end,:);initPath(end,:)+0.01*move;initPath(end,:)+lead*move];
                on_off=[on_off;1;0;0];
                traverse=[traverse;0;0;0];
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