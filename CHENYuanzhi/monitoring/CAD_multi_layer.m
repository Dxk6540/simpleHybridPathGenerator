%%%%%%%%%%%%%%%%%%%
%
% date: 2023-5-15
% author: CHEN Yuanzhi
%
%%%%%%%%%%%%%%%%%%

% file param:
P_pattern = ["const", "tooth", "sin", "noise"];
F_pattern = ["const", "tooth", "sin", "noise"];
Reverse = 0;
dxfFile='Drawing7.dxf';
i=1;j=3;B_axis=5;
skip=200;

% printing process param
pwr = 200; % 1.2KW / 4kw *1000;
pFeedrate = 600; % mm/min
lenPos = 800;
flowL = 250; % 6 L/min / 20L/min * 1000;
speedL = 100;% 2 r/min / 10r/min * 1000;
flowR = 400;% 6 L/min / 20L/min * 1000;
speedR = 100;% 2 r/min / 10r/min * 1000;
safetyHeight = 45;
traverse=2000;

% shape
handle = CADMultiplelayer;
z_offset=3.8;
if exist('./Z.mat', 'file')
    % 如果文件夹不存在，使用mkdir函数创建新的文件夹
    load('Z');
else
    load(strcat('./',erase(dxfFile,'.dxf'),'_CADPrint_path.mat'));
    data=zeros(length(pPathSeq),1);
end
Z_coord=z_offset+data';

%%
%%%%%%%%%%%%%% printing path
%%%% the regular code for generate a script
hFilename = strcat('./',erase(dxfFile,'.dxf'),'_CADMLPrint_',P_pattern(i),'_',F_pattern(j),'.txt');
pg = cPathGen(hFilename); % create the path generator object
pg.genNewScript();
%%% Beam1
pg.changeMode(1); % change to printing mode
[pPathSeq,pwrSeq, pFeedrateSeq,vertices] = handle.genPrintingPath(pPathSeq, pwr, pFeedrate, traverse, P_pattern(i), F_pattern(j), Reverse, B_axis, Z_coord);
lenPosSeq = ones(length(pPathSeq),1) * lenPos;
%%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%
%%% start printing mode
pg.setLaser(0, lenPos, flowL, speedL, flowR, speedR); % set a init process param (in case of overshoot)
pg.startRTCP(safetyHeight, 16); 
pg.addPathPts([0,0,safetyHeight,0,0], 3000);
pg.addPathPts([0,0,safetyHeight,0,0], 3000);
pg.saftyToPt([nan, nan, safetyHeight], pPathSeq(1,:), 500); % safety move the start pt
pg.enableLaser(1, 10);
pg.addCmd("M440");
%%% add path pts
pg.addPathPtsWithPwr(pPathSeq, pwrSeq, lenPosSeq, pFeedrateSeq);
%%% exist printing mode
pg.disableLaser(1);
pg.addCmd("M441");
pg.stopRTCP(safetyHeight, 16); 
pg.addPathPts([-115,-4,120,0,0], 2000);
%%% draw
pg.draw_ = false;
%pg.drawPath(pPathSeq, pPathSeq);
saveName=strcat('CADMLPrint_',P_pattern(i),'_',F_pattern(j),'.mat');
save(saveName,'pPathSeq','pwrSeq','pFeedrateSeq');
%% end the script
pg.closeScript();