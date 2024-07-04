function [seq,reverse,group]=connectPoints(SE)
    input=SE;
    num=length(SE)/2;
    seq=ones(1,num);
    reverse=zeros(1,num);
    closest=SE(2,:);
    group=ones(1,num);
    SE=SE(3:end,:);
    index=2:num;
    for i=2:num
        cost=vecnorm((SE-closest)');
        [dist,currentIndex]=min(cost);
        if rem(currentIndex,2)==0
            reverse(i)=1;
            closest=SE(currentIndex-1,:);
            SE(currentIndex-1:currentIndex,:)=[];
            seq(i)=index(currentIndex/2);
            index(currentIndex/2)=[];
        else
            closest=SE(currentIndex+1,:);
            SE(currentIndex:currentIndex+1,:)=[];     
            seq(i)=index((currentIndex+1)/2);
            index((currentIndex+1)/2)=[];
        end
        if dist<0.01
            group(i)=group(i-1);
        else
            group(i)=group(i-1)+1;
        end
    end
    points=[];
    for i=1:num
        if reverse(i)==1
            points=[points;input(2*seq(i),:);input(2*seq(i)-1,:)];
        else
            points=[points;input(2*seq(i)-1,:);input(2*seq(i),:)];
        end
    end
    plot(points(:,1),points(:,2));
    axis equal
end