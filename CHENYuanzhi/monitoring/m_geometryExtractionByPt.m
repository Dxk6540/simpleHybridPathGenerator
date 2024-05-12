clear;clc;
tic;
%% Library file
addpath(genpath('./sigmoid'));
%% Choose the data
% addpath('./0_data');
% addpath('./ptCloud');
load fileLists.mat;
%% Choose the point cloud
% addpath(genpath('../interval_1_200'));
load coarseTform.mat;

tic;

rot=[-0.0229250733230717	-0.999731260292429	0.00344212249094134;
-0.961007223223508	0.0229858711126532	0.275566265427094;
-0.275571330013438	0.00300947226326656	-0.961275915204018];
trans=[-0.0397680989680111	-69.1075138555469	263.208628507888];
% ttt=[-0.0229250733230717	-0.999731260292429	0.00344212249094134 -0.0397680989680111;
% -0.961007223223508	0.0229858711126532	0.275566265427094 -69.1075138555469;
% -0.275571330013438	0.00300947226326656	-0.961275915204018 263.208628507888;
% 0 0 0 1];
tform = rigid3d(rot,trans);
fileName='parameters.mat';
for i=1:12
    ptCloud=pcread(strcat(num2str(i),'/12000.ply'));%ply格式文件用pcread读取
    pts=ptCloud.Location*rot'+trans;
    ptCloud=pointCloud(pts);
    tform=rigid3d([1 0 0;0 1 0;0 0 1],[0 0 0]);
%     group=Group(ptCloud,tform,num2str(i),[-55,55,-55,55,3,10],true);%Input:s ptcloud, tform, name, display the ROI
    group=Group(ptCloud,tform,num2str(i),[-37,37,-40,40,3,10],false);%Input:s ptcloud, tform, name, display the ROI
    group.printROI=[-33,33,-38,38,3,10];%Real printing area
    channelPattern=24042301;
    for j=1:16
        group.deployChannels(channelPattern);
        group.extractChannels();
%         group.displayChannels();
        channel=group.channels{j,3};
        channel.ptCloud = pcdenoise(channel.ptCloud,'NumNeighbors',128);
        channel.preciseTransform(false);
        channel.createMesh();
        channel.smoothMesh();
%         channel.displayMesh();
%         channel.displaySmoothedMesh();
        % channel.displayContour();
        % channel.displaySmoothedContour();
        for k=1:201%%%%！！！！！！！！！！
%             if i==2&&j==16&&(k>50)&&(k<58)
%                 continue;
%             end
            filePath="E:\Code\LSTM\cnn-lstm\datasets\interval_16_201\";%%%%！！！！！！！！！！
            if ~exist(filePath,'dir')
                return;
            end
            filePath=filePath+num2str(fileLists(i,2))+"_"+num2str(fileLists(i,3))+"_"+num2str(j)+"_"+num2str(k);
            load(fullfile(filePath, fileName));
            Y=samplepoint(2);
            %% W and H extraction
            channel.sigmoidParas=[];
            tempParas=channel.sigmoidParasExtraction(Y);%% [zoom_par,moving_par,symmetry_axis,height,width,area]
            fileID = fopen(fullfile(filePath, 'results.txt'), 'w');
            text=strcat(num2str(tempParas(4)),',',num2str(tempParas(5)),',',num2str(tempParas(6)));
            fprintf(fileID, '%s', text);
            fclose(fileID);
        end
    end
end
toc;
fangboa=1;
% % % %% Display the printing area
% % % % figure('Name','The printing area')
% % % % hold on;
% % % % axis equal;
% % % % rotate3d;
% % % % pcshow(group.printPtCloud);
% % % % % plot3(pathSeq(:,1),pathSeq(:,2),pathSeq(:,3),'LineWidth',2);
% % % %% Channel
% % % group.deployChannels(channelPattern);
% % % group.extractChannels();
% % % % group.displayChannels();
% % % channel=group.channels{1,3};
% % % channel.ptCloud = pcdenoise(channel.ptCloud,'NumNeighbors',128);
% % % channel.preciseTransform(false);
% % % channel.createMesh();
% % % channel.smoothMesh();
% % % % channel.displayMesh();
% % % % channel.displaySmoothedMesh();
% % % % channel.displayContour();
% % % % channel.displaySmoothedContour();
% % % %% W and H extraction
% % % channel.sigmoidParas=[];
% % % 
% % % Y=[-10,-5];
% % % 
% % % aa=channel.sigmoidParasExtraction(Y);%% [zoom_par,moving_par,symmetry_axis,height,width,area]
% % % channel.sigmoidParas=[channel.sigmoidParas,channel.mesh_y(:,1)];% Here don't save X and Z data, because X can be replaced by the para3————the position of symmetry axis;
% % % % channel.sigmoidParas((channel.mesh_y(:,1)>=-15)+(channel.mesh_y(:,1)<=15)<2,:)=[];% Choose the useful range
% % % % channel.displaySigmoidParasAlongY(1);
% % % % channel.smoothSigmoidParas(channel.sigmoidParas,-1);
% % % % channel.displaySigmoidParasAlongY(2);
% % % clear X Z zAlign tform tempSigmoidParas q paras middleX j forAlignZ;
% % % %% Display width and height
% % % channel.smoothSigmoidParas(channel.sigmoidParas,-1);
% % % sigmoidParas=channel.sigmoidParas;
% % % figure('Name','height and width')
% % % subplot(2,1,1);
% % % plot(sigmoidParas(:,end),sigmoidParas(:,5),'LineWidth',2);
% % % hold on;
% % % % plot(channel.smoothedSigmoidParas(:,end),channel.smoothedSigmoidParas(:,5),'LineWidth',2);
% % % % ylim([1.6,2.6]);
% % % xlabel('Y [mm]');
% % % ylabel('width [mm]');
% % % subplot(2,1,2);
% % % plot(sigmoidParas(:,end),sigmoidParas(:,4),'LineWidth',2);
% % % hold on;
% % % % plot(channel.smoothedSigmoidParas(:,end),channel.smoothedSigmoidParas(:,4),'LineWidth',2);
% % % % ylim([0.15,0.45]);
% % % xlabel('Y [mm]');
% % % ylabel('height [mm]');
% % % %% Output the data
% % % originalData=channel.sigmoidParas;% 1 scaling, 2 stretching, 3 the position of the symmetry axis, 4 shifting 5 width, 6 Y position
% % % data=[channel.smoothedSigmoidParas(:,7),channel.smoothedSigmoidParas(:,5),channel.smoothedSigmoidParas(:,4),channel.smoothedSigmoidParas(:,6),];% 1 distance, 2 Y position, 3 width, 4 height, area
% % % if (mod(channel.index,2)==0)
% % %     data=flip(data,1);
% % %     originalData=flip(originalData,1);
% % % end
% % % data=[[0;abs(data(2:end,1)-data(1:end-1,1))],data];
% % % for i=2:size(data,1)
% % %     data(i,1)=data(i,1)+data(i-1,1);
% % % end
% % % disp(['Time cost：', num2str(toc), ' s.']);
% % % 
% % % % staticData=[mean(originalData(:,5)),std(originalData(:,5)),mean(originalData(:,4)),std(originalData(:,4))];
% % % 
% % % staticData1=[mean(originalData(1:end/3,5)),std(originalData(1:end/3,5)),mean(originalData(1:end/3,4)),std(originalData(1:end/3,4))];
% % % staticData2=[mean(originalData(2*end/3:end,5)),std(originalData(2*end/3:end,5)),mean(originalData(2*end/3:end,4)),std(originalData(2*end/3:end,4))];