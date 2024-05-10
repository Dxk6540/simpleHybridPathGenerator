function displayContour(obj)
title=sprintf('Contour map of the channel');
figure('Name',title);
[C,h] = contourf(obj.mesh_y,obj.mesh_x,obj.mesh_z,15);
axis equal;
colorbar;
clim([0, 0.6]);
axis equal;
ylabel('x [mm]','FontSize',12,'FontName','Times New Roman','Color','k');
xlabel('y [mm]','FontSize',12,'FontName','Times New Roman','Color','k');

figure('Name','Medial plane');
plot(obj.mesh_y(:,1),obj.mesh_z(:,end/2));
ylim([0,0.6]);
ylabel('x [mm]','FontSize',12,'FontName','Times New Roman','Color','k');
xlabel('y [mm]','FontSize',12,'FontName','Times New Roman','Color','k');
end

