classdef Channel < handle
    properties
        %% initialization
        name;
        index;
        boundary;
        ptCloud;
        preciseTform;
        %% mesh
        mesh_x;
        mesh_y;
        mesh_z;
        mesh_smoothedZ;%% I think the results are too smoothed --Eric
        %% width, height
        sigmoid;
        sigmoidParas;% Used for sigmoidParas along Y
        smoothedSigmoidParas;% Used for sigmoidParas along Y
        xData;
        zData;
        width;
        height;
    end
    methods
        function obj = Channel(boundary,ptcloud,name,index)
            obj.boundary=boundary;
            obj.ptCloud=ptcloud;
            obj.name=name;
            obj.index=index;
        end
    end
end