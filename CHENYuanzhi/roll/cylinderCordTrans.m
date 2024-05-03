function [transformedPts,transformedNorms] = cylinderCordTrans(pts, normals, cylinderAxis, cylinderOrin)
    zNew = cylinderAxis/norm(cylinderAxis);
    x = [0,0,1];
    xNew = x - (x*zNew')*zNew;
    xNew = xNew/norm(xNew);
    yNew = cross(xNew, zNew);
    yNew = yNew/norm(yNew);
    trans = [xNew', yNew', zNew'];

    transformedPts = pts*trans'+ repmat(cylinderOrin,length(pts),1);
    transformedNorms = normals*trans';

end