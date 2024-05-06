function [r, axis, cntr] = getCylinderParam(filename)
mcsPts = load(filename);

maxDistance = 5e-3;
referenceVector = [0,0,1];
pcWcsPts = pointCloud(mcsPts);

cylinderModel = pcfitcylinder(pcWcsPts,maxDistance, referenceVector);
r = cylinderModel.Radius;
axis = cylinderModel.Orientation/norm(cylinderModel.Orientation);
cntr = cylinderModel.Center;
end
