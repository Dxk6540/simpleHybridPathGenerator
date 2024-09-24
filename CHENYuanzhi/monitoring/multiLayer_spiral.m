function [Zs] = multiLayer_spiral(vertices)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%% Description: Extract the cross-section pattern of the spiral bead geometry
% -------------------------------------------------------------------------
% Author:        Eric
% Date:          2024-09-24
% -------------------------------------------------------------------------
addpath('./test');
%% Library file
addpath(genpath('../library'));
%% File path
path_data=dataPath('13900K');
[name_project,name_exp,name_resources,path_file,path_resources,path_results] = path_24070401(path_data);
%% Group file
tformPath=fullfile(path_file,'calibration','coarseTform.mat');
ptCloudPath=fullfile(path_resources,'10000.ply');
load (tformPath);
%% Create group
targetROI=[-55,55,-55,55,-1,5];
printingROI=[-38,38,-39,39,-1,5];
ptCloud=pcread(ptCloudPath); % ply -> pcread
group=Group(ptCloud,tform,name_resources,targetROI,false);%Input:s ptcloud, tform, name, display the ROI
% group.preciseTransform(printingROI,false);
% group.addPrintingPath(printingPath,false);
%% Get the point and vector
%%
%%
group.printingPath=group.printingPath-[0.15,0.45,0];
vs=vertices(2:end,1:3)-vertices(1:end-1,1:3);
pts=vertices(1:end-1,1:3);
selectSeq=1:size(pts,1);
Zs=[];
for i=1:length(selectSeq)
    ptIndex=selectSeq(i);
    [~,WHA,profile,~]=group.getProfile4Spiral(pts(ptIndex,:),vs(ptIndex,:),1);
    if ~isempty(profile)
        Zs=[Zs;WHA{2}];
%         inf(i).width=WHA{1};
%         inf(i).height=WHA{2};
%         inf(i).area=WHA{3};
%         inf(i).profile=profile(:,1:2);
%         inf(i).smoothedProfile=profile(:,[1,3]);
%         inf(i).simulatedResults=profile(:,[1,4]);
%         inf(i).paras_piecewise=paras_piecewise;
    end
end
Zs=[Zs;Zs(end)];
end