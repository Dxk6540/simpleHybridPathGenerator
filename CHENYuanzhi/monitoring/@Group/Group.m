classdef Group < handle
    properties
        path;
        %% Calibration
        ptCloud;% Store the input pointcloud, then updated by ROI extraction and calibration
        coarseTform; % transform matrix
        ROI;
        preciseTform; % transform matrix
        %% Experiment group
        printROI;
        printPtCloud;
        %% Channel
        name;
        channelsInf; % 1~3 is the center point of the channel; 4 for feedrate, 5 for power.
        channels_ROI;
        channels;
    end
    methods
        function obj = Group(ptCloud,tform,name,ROI,display)
            obj.name=name;
            obj.path=path;
            obj.coarseTform=tform;
            obj.ROI=ROI;
            ptCloud=pctransform(ptCloud,obj.coarseTform);
            indices = findPointsInROI(ptCloud,obj.ROI);
            obj.ptCloud = select(ptCloud,indices);
            obj.printPtCloud=obj.ptCloud;
            % Display the ROI
            if display
                figure('Name','Extract the ROI');
                pcshow(obj.ptCloud);
            end
        end
    end
end