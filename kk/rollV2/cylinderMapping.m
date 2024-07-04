function [agl,height] = cylinderMapping(path,center,nominalRadius,offset)
    agl=(path(:,2)+center(2))*180/pi/nominalRadius;
    height=offset+path(:,1)+center(1);
end