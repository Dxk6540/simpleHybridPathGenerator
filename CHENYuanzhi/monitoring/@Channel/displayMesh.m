function displayMesh(obj)
%% Display the mesh
title=sprintf('Mesh of the channel, index: %d', obj.index);
figure('Name',title);
xlabel('x [mm]')
ylabel('y [mm]')
zlabel('z [mm]')
surf(obj.mesh_x,obj.mesh_y,obj.mesh_z);
colorbar;
% clim([0, 1]);
shading interp;
axis equal;
end