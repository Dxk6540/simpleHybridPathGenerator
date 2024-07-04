function [path,on_off,traverse]=genRollShoulder(xRange, finalRadius, step)
    tol = 0.2;
    yLength = finalRadius * 2 * pi;
    step = 1;
    channelNum =  round((xRange(2) - xRange(1))/step);
    xPos = linspace(xRange(1), xRange(2), channelNum);
    channelPts = cell(channelNum, 1);
    ptNum = round(yLength);
    yPos = linspace(0, yLength, ptNum);
    shift = 2;
    startY = 0;
    for i = 1:channelNum
        curX = xPos(i);
        curY = yPos + startY;
        channelPts{i} = [curX, 0] + curY'*[0 1];
        yPos = fliplr(yPos);
%         startY = shift + startY + yLength;
    end

% num=length(seq);
    lead=3;
    theta=120/180*pi;
    path=[];
    on_off=[];
    traverse=[];
    for i=1:(channelNum-1)
        initPath = channelPts{i};

        if size(initPath,1)~=1
%             % lead in
%             move=(initPath(1,:)-initPath(2,:))/norm(initPath(1,:)-initPath(2,:)); % movDir
%             path=[path;initPath(1,:)+lead*move;initPath(1,:)+0.01*move];
%             on_off=[on_off;0;0];
%             traverse=[traverse;0;0];            

            for j=1:size(initPath,1)-1
%                 % fishtail
%                 if on_off(end)==1
%                     p0=path(end,:);
%                     p1=initPath(j,:);
%                     p2=initPath(j+1,:);
%                     d1=(p0-p1)/norm(p0-p1);d2=(p2-p1)/norm(p2-p1);
%                     if acos(sum(d1.*d2)) < theta
%                         path=[path;path(end,:)-0.01*d1;path(end,:)-lead*d1;path(end,:)-lead*d2;path(end,:)-0.01*d2];
%                         on_off=[on_off;0;0;0;0];
%                         traverse=[traverse;1;1;1;1];
%                     end
%                 end
                % print path, interp
                path=[path;initPath(j,:)];
                on_off=[on_off;1];
                traverse=[traverse;0];
                dist=norm(initPath(j+1,:)-initPath(j,:));
                if dist>tol
                    count=floor(dist/tol);
                    move=(initPath(j+1,:)-initPath(j,:))/count;
                    path=[path;initPath(j,:)+move.*(1:count-1)'];
                    on_off=[on_off;ones(count-1,1)];
                    traverse=[traverse;zeros(count-1,1)];
                end
            end
            
%             %lead out
%             move=(initPath(end,:)-initPath(end-1,:))/norm(initPath(end,:)-initPath(end-1,:));
%             path=[path;initPath(end,:);initPath(end,:)+0.01*move;initPath(end,:)+lead*move];
%             on_off=[on_off;1;0;0];
%             traverse=[traverse;0;0;0];            
        end
        
        % air-move
        head=path(end,:);
        tail = channelPts{i+1}(1,:);
        dist=norm(tail-head);
        if dist>tol
            count=floor(dist/tol);
            move=(tail-head)/count;
            path=[path;head+move.*(1:count-1)'];
            on_off=[on_off;zeros(count-1,1)];
            traverse=[traverse;ones(count-1,1)];
        end
    end
    plot(path(:,1),path(:,2));    
end