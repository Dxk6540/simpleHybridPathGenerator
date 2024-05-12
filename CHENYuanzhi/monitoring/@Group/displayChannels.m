function displayChannels(obj)
figure('Name','Channels on the substrate')
pcshow(obj.ptCloud);
hold on;
axis equal;
for i=1:size(obj.channels,1)
    channel=obj.channels{i,3};
    plot3(channel.ptCloud.Location(:,1),channel.ptCloud.Location(:,2),channel.ptCloud.Location(:,3),'.');
end
end

