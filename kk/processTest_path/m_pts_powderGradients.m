clear;clc;
addpath('1_resources');
% load paras_powderGradients_selectedHRC55.mat;
load paras_DC_ForHammer_mixPowder.mat
%% 1-EDR, 2-EMS, 3-layerHeight, 4-layerNum, 5-6 intial powder ratio, 7-8 final powder ratio, 9- laser melting (1-首层熔覆�?2-每层熔覆, 3-每层熔覆了顶层再熔覆), 10-mix powder at the first layer
resultsPath='./2_results';
expIndex=24052104;
channelInfo={};
for i=1:size(paras_powderGradients,1)
    pts_eachLayer = ptsWithPowderGradients(paras_powderGradients(i,:));
    channelInfo{i}=pts_eachLayer;
end
channelInfo=channelInfo';
filename = strcat(num2str(expIndex),'_channelParas');
filePath=fullfile(resultsPath,filename);
save(filePath, 'channelInfo');

%% Path infomation
pathSign=(-30:7.5:30)';
pathSign=[pathSign;pathSign];
pathSign(1:end/2,2)=-19;
pathSign(end/2+1:end,2)=19;
pathSign(:,3)=0;
halfLine=32/2;
emptySpeed=200/60;
%% Channel generation
count=0;
pathSeq=[];
for k=1:length(channelInfo)
    parasLayer=channelInfo{k};
    if k>=size(pathSign,1)
        i=mod(k,size(pathSign,1));
        if i==0
            i=size(pathSign,1);
        end
    else
        i=k;
    end
    for j=1:size(channelInfo{i},1)
        tempPts=[
            pathSign(i,1:3)-[0,halfLine+8,0];
            pathSign(i,1:3)-[0,halfLine+1,0];
            pathSign(i,1:3)-[0,halfLine,0];
            pathSign(i,1:3);
            pathSign(i,1:3)+[0,halfLine,0];
            pathSign(i,1:3)+[0,halfLine+1,0];
            pathSign(i,1:3)+[0,halfLine+8,0
            ];
        tempPts=tempPts+[0 0 parasLayer(j,3)];
        tempEDR_EMS=[
        [0,emptySpeed];
        [0,parasLayer(j,2)];
        [parasLayer(j,1),parasLayer(j,2)];
        [parasLayer(j,1),parasLayer(j,2)];
        [parasLayer(j,1),parasLayer(j,2)];
        [parasLayer(j,1),parasLayer(j,2)];
        [0,parasLayer(j,2)]
        ];
        tempPowderMode=ones(size(tempPts,1),1)*parasLayer(j,4:5);
        pathSeq=[pathSeq;tempPts,tempEDR_EMS,tempPowderMode];
    end
    if i==size(pathSign,1)
        count=count+1;
        filename = strcat(num2str(expIndex),'_channelPts_',num2str(count));
        filePath=fullfile(resultsPath,filename);
        pathSeq=[[-35,-30,pathSeq(1,3:7)];pathSeq];
        save(filePath, 'pathSeq');
        pathSeq=[];
    end
end
if(~isempty(pathSeq))
    count=count+1;
    filename = strcat(num2str(expIndex),'_channelPts_',num2str(count));
    filePath=fullfile(resultsPath,filename);
    pathSeq=[[-35,-30,pathSeq(1,3:end)];pathSeq];
    save(filePath, 'pathSeq');
end
