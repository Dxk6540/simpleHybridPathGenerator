function [pathSeq,feedSeq] = convolutionSmooth(initial_pathSeq,initial_feed,kernel,Splan_visible)
initial_pathSeq(end,:)=[];
initial_feed(end)=[];

dist=10+sqrt(sum((initial_pathSeq-initial_pathSeq(1,:)).^2,2));
feed=initial_feed;
for i=1:100
    dist=[dist(1)-0.005;dist];
    feed=[feed(1);feed];

    dist=[dist;dist(end)+0.005];
    feed=[feed;feed(end)];
end

kernel=1/50*ones(50,1);
feedSeq=conv(feed,kernel,'same');
figure('Name','S-shaped speed curve');
plot(dist, feed);
hold on;
plot(dist, feedSeq);
load a100_acc.mat;
plot(test(:,1), test(:,2));
xlabel('Distance [mm]');
ylabel('Speed [mm/s]');



dist=dist+0.125;
for i=1:size(dist,1)
    fprintf('G01 X%.4f Y%.4f Z%.4f F%.4f\n',dist(i),0,0,feedSeq(i)*60);
end
a=10;
end