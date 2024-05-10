function channels = extractChannels(obj)
%% Extract channels
channels=cell(size(obj.channels_ROI,1),3);
for i=1:size(obj.channels_ROI,1)
    indices = findPointsInROI(obj.printPtCloud,obj.channels_ROI(i,:));
    ptCloud = select(obj.printPtCloud,indices);
    ptCloud=pcdenoise(ptCloud);
%     figure('Name','Extracted channels')
%     hold on;
%     pcshow(obj.printPtCloud);
%     plot3(ptCloud.Location(:,1),ptCloud.Location(:,2),ptCloud.Location(:,3));
    channels(i,:)={obj.name,obj.channelsInf(i,4),Channel(obj.channels_ROI(i,:),ptCloud,obj.channelsInf(i,4),i)};
    obj.channels=channels;
end
end