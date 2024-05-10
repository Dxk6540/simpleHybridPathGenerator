function [centerPts,channelsROI] = deployChannels(obj,experimentIndex)
%% Experiment: #24012901
if experimentIndex==24012901
    %% Determine the channels' ROI
    centerPts=[-30,0,0;
        -22.5,0,0;
        -15,0,0;
        -7.5,0,0;
        0,0,0;
        7.5,0,0;
        15,0,0;
        22.5,0,0;
        30,0,0];
    channelsROI=[];
    for i=1:size(centerPts,1)
        channelsROI=[channelsROI;[centerPts(i,1)-4,centerPts(i,1)+4,centerPts(i,2)-25,centerPts(i,2)+25,centerPts(i,3)-2,centerPts(i,3)+4]];
    end
    names=-1*ones(size(centerPts,1),1);
end
%% Experiment: #24012901
if experimentIndex==24012902
    %% Determine the channels' ROI
    centerPts=[-30,0,0;
        -18,0,0;
        -6,0,0;
        6,0,0;
        18,0,0;
        30,0,0];
    channelsROI=[];
    for i=1:size(centerPts,1)
        channelsROI=[channelsROI;[centerPts(i,1)-4,centerPts(i,1)+4,centerPts(i,2)-25,centerPts(i,2)+25,centerPts(i,3)-2,centerPts(i,3)+4]];
    end
    names=-1*ones(size(centerPts,1),1);
end
%% Experiment: #24012901
if experimentIndex==23111601
    %% Determine the channels' ROI
    centerPts=[-30,0,0;
        -18,0,0;
        -6,0,0;
        6,0,0;
        18,0,0];
    channelsROI=[];
    for i=1:size(centerPts,1)
        channelsROI=[channelsROI;[centerPts(i,1)-4,centerPts(i,1)+4,centerPts(i,2)-25,centerPts(i,2)+25,centerPts(i,3)-2,centerPts(i,3)+4]];
    end
    names=[6.666;8.333;10;11.666;13.333];
end
%% Experiment: #23121202
if experimentIndex==23121202
    %% Determine the channels' ROI
    centerPts=[0,-5,0;
        5,10,0;
        0,-15,0;
        5,20,0;
        0,-25,0;
        5,30,0;
        0,-35,0];
    channelsROI=[];
    for i=1:size(centerPts,1)
        channelsROI=[channelsROI;[centerPts(i,1)-3,centerPts(i,1)+3,centerPts(i,2)-2,centerPts(i,2)+2,centerPts(i,3)-2,centerPts(i,3)+4]];
    end
    names=[5;10;15;20;25;30;35];
end
%% Experiment: #24042301
if experimentIndex==24042301
    %% Determine the channels' ROI
    centerPts=[-28,-17.5,5;
        -20,-17.5,5;
        -12,-17.5,5;
        -4,-17.5,5;
        4,-17.5,5;
        12,-17.5,5;
        20,-17.5,5;
        28,-17.5,5;
        -28,17.5,5;
        -20,17.5,5;
        -12,17.5,5;
        -4,17.5,5;
        4,17.5,5;
        12,17.5,5;
        20,17.5,5;
        28,17.5,5;];
    channelsROI=[];
    for i=1:size(centerPts,1)
        channelsROI=[channelsROI;[centerPts(i,1)-4,centerPts(i,1)+4,centerPts(i,2)-17.5,centerPts(i,2)+17.5,centerPts(i,3)-2,centerPts(i,3)+4]];
    end
    names=(1:16)';
end
obj.channelsInf=[centerPts,names];
obj.channels_ROI=channelsROI;
end

