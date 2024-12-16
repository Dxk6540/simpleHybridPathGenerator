%%%%%%%%%%%%%%%%%%%
%
% date: 2023-5-15
% author: CHEN Yuanzhi
%
%%%%%%%%%%%%%%%%%%

% file param:
P_pattern = ["const", "tooth", "sin", "square","noise"];
F_pattern = ["const", "tooth", "sin", "square","noise"];
Rtcp_use = 0;
Reverse = 1;
dxfFile='Drawing6.dxf';
i=1;j=2;
skip=200;

% printing process param
pwr = 200; % 1.2KW / 4kw *1000;
pFeedrate = 400; % mm/min
lenPos = 600;
flowL = 250; % 6 L/min / 20L/min * 1000;
speedL = 100;% 2 r/min / 10r/min * 1000;
flowR = 400;% 6 L/min / 20L/min * 1000;
speedR = 100;% 2 r/min / 10r/min * 1000;
safetyHeight = 25;

%  geometry param
traverse=2000;
% shape
handle = CADSamplesinglelayer;

%%
%%%%%%%%%%%%%% printing path
%%%% the regular code for generate a script
hFilename = strcat('./',erase(dxfFile,'.dxf'),'_CADPrint_',P_pattern(i),'_',F_pattern(j),'.txt');
pg = cPathGen(hFilename); % create the path generator object
pg.genNewScript();
%%% Beam1
pg.changeMode(1); % change to printing mode
[pPathSeq,pwrSeq, pFeedrateSeq,vertices] = handle.genPrintingPath(pwr, pFeedrate, traverse, P_pattern(i), F_pattern(j), Rtcp_use, dxfFile, skip, Reverse);
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
pg.addPathPts([-120,0,120,0,0], 2000);
%%% draw
pg.draw_ = false;
%pg.drawPath(pPathSeq, pPathSeq);
saveName=strcat('CADPrint_',P_pattern(i),'_',F_pattern(j),'.mat');
save(saveName,'pPathSeq','pwrSeq','pFeedrateSeq');
%% end the script
pg.closeScript();
pPathSeq=pPathSeq(4:end-2,:);
vector=pPathSeq(2:end,:)-pPathSeq(1:end-1,:);
vector=[vector;vector(end,:)];
save(strcat('./',erase(dxfFile,'.dxf'),'_CADPrint_vector.mat'),'vector');
save(strcat('./',erase(dxfFile,'.dxf'),'_CADPrint_path.mat'),'pPathSeq');
save(strcat('./',erase(dxfFile,'.dxf'),'_CADPrint_vertices.mat'),'vertices');