function preciseTransform(obj,show)
%% Calculate the precise transform matrix
%% Extract the substrate plane
if(show)
    figure('Name','After precise transform')
    hold on;
    axis equal;
    rotate3d;
    pcshow(obj.ptCloud);
end
% % Choose part point cloud
% x_width=obj.boundary(2)-obj.boundary(1);
% if x_width<=4
%     return;
% end
% ROI=[obj.boundary(1),(obj.boundary(1)+obj.boundary(2))/2-2,obj.boundary(3:6)];
% internalRectangle = findPointsInROI(obj.ptCloud,ROI);
% ptCloudROI4 = select(obj.ptCloud,internalRectangle);
% ROI=[(obj.boundary(1)+obj.boundary(2))/2+2,obj.boundary(2),obj.boundary(3:6)];
% internalRectangle = findPointsInROI(obj.ptCloud,ROI);
% ptCloudROI5 = select(obj.ptCloud,internalRectangle);
% ptCloudROI3=pointCloud([ptCloudROI4.Location;ptCloudROI5.Location]);
ptCloudROI3=obj.ptCloud;
%% Fit the plane, make the normal of the plane along the Z-axis, and deploy the ptcloud on the XY plane
substrate=pcfitplane(ptCloudROI3,0.01,[0 0 1]);% The distance must be a very large value, or two point clouds won't be fit together
tform = normalRotation(substrate,[0,0,1]);
tempPC=pctransform(ptCloudROI3,tform);
zMean=min(tempPC.Location(:,3));
tform.Translation=tform.Translation+[0,0,0];%-zMean
obj.preciseTform=tform;
obj.ptCloud=pctransform(obj.ptCloud,obj.preciseTform);
%% Display
if(show)
    pcshow(obj.ptCloud);
    plot3(ptCloudROI3.Location(:,1),ptCloudROI3.Location(:,2),ptCloudROI3.Location(:,3),'o',Color='g');
    substrate.plot();
end
% % %% Extract the printed area's pointcloud
% % indices = findPointsInROI(obj.ptCloud,obj.printROI);
% % obj.printPtCloud = select(obj.ptCloud,indices);
% % if(show)
% %     figure('Name','Printing area after precise transform')
% %     hold on;
% %     axis equal;
% %     rotate3d;
% %     pcshow(obj.printPtCloud);
% % end
end