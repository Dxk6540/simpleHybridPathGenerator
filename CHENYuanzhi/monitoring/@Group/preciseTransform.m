function preciseTransform(obj,ROI,show)
%% Calculate the precise transform matrix
%% Extract the substrate plane
if(show)
    figure('Name','After precise transform')
    hold on;
    axis equal;
    rotate3d;
    pcshow(obj.ptCloud);
end
internalRectangle = findPointsInROI(obj.ptCloud,ROI);
ptCloudROI3 = select(obj.ptCloud,internalRectangle);
%% Fit the plane, make the normal of the plane along the Z-axis, and deploy the ptcloud on the XY plane
xMeanOri=mean(ptCloudROI3.XLimits);
yMeanOri=mean(ptCloudROI3.YLimits);
ptCloudROI3 = pcdenoise(ptCloudROI3,'NumNeighbors',128);
substrate=pcfitplane(ptCloudROI3,0.01,[0,0,1]);
tform = normalRotation(substrate,[0,0,1]);
tempPC=pctransform(ptCloudROI3,tform);
xMeanTemp=mean(tempPC.XLimits);
yMeanTemp=mean(tempPC.YLimits);
zMean=mean(tempPC.Location(:,3));
tform.Translation=tform.Translation+[-(xMeanTemp-xMeanOri),-(yMeanTemp-yMeanOri),-zMean];
obj.preciseTform=tform;
obj.ptCloud=pctransform(obj.ptCloud,obj.preciseTform);
%% Display
if(show)
    pcshow(obj.ptCloud);
    plot3(ptCloudROI3.Location(:,1),ptCloudROI3.Location(:,2),ptCloudROI3.Location(:,3),'o',Color='g');
    substrate.plot();
end
%% Extract the printed area's pointcloud
indices = findPointsInROI(obj.ptCloud,obj.printROI);
obj.printPtCloud = select(obj.ptCloud,indices);
if(show)
    figure('Name','Printing area after precise transform')
    hold on;
    axis equal;
    rotate3d;
    pcshow(obj.printPtCloud);
end
end