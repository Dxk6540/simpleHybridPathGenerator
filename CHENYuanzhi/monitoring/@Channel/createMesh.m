function [X,Y,Z]=createMesh(obj)
%% Create the mesh
ptCloud=double(obj.ptCloud.Location);
interpolantXYZ = scatteredInterpolant(ptCloud(:,1), ptCloud(:,2), ptCloud(:,3));
pixel_size_x = 0.05; %[mm] the pixel size applied in the interpolation
pixel_size_y = 0.05; %[mm] the pixel size applied in the interpolation
x_min = obj.boundary(1);
x_max = obj.boundary(2);
y_min = obj.boundary(3);
y_max = obj.boundary(4);
x_num = floor((x_max - x_min) / pixel_size_x);
y_num = floor((y_max - y_min) / pixel_size_y);
[X,Y] = meshgrid(linspace(x_min,x_max,x_num),linspace(y_min,y_max,y_num));
Z = interpolantXYZ(X,Y);
obj.mesh_x=X;
obj.mesh_y=Y;
obj.mesh_z=Z;
end