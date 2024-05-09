function [r, axis, cntr] = getCylinderParam(filename)
mcsPts = load(filename);

maxDistance = 5e-3;
referenceVector = [0,0,1];
pcWcsPts = pointCloud(mcsPts);
% pcnormals(pcWcsPts,'K',8)
normals = [];
num =6;
for i = 1:num
    normals = [normals; cos(i*pi/num*2),sin(i*pi/num*2),0];
end
lyr = 4;
newNorm = [];
for i = 1:lyr
    newNorm = [newNorm;normals];
end
pcWcsPts.Normal = -newNorm;


% cylinderModel = pcfitcylinder(pcWcsPts,maxDistance,referenceVector,10,'MaxNumTrials',1e6);
% cylinderModel = pcfitcylinder(pcWcsPts,maxDistance, referenceVector, 'MaxNumTrials',1e6);

maxDistance = 2e-3;
cylinderModel = pcfitcylinder(pcWcsPts,maxDistance, referenceVector);

% maxDistance = 1e-2;
% pcWcsPts = pointCloud(mcsPts);
% cylinderModel = pcfitcylinder(pcWcsPts,maxDistance);
r = cylinderModel.Radius;
axis = cylinderModel.Orientation/norm(cylinderModel.Orientation);
cntr = cylinderModel.Center;
end
