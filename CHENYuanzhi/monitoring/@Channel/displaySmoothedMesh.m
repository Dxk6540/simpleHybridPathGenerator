function displaySmoothedMesh(obj)
%% Display the mesh
title=sprintf('Smoothed mesh of the channel, index: %d',obj.index);
figure('Name',title);
xlabel('x [mm]')
ylabel('y [mm]')
zlabel('z [mm]')
surf(obj.mesh_x,obj.mesh_y,obj.mesh_smoothedZ);
colorbar;
shading interp;
axis equal;
end