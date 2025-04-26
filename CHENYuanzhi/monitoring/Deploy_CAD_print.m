%%%%%%%%%%%%%%%%%%%
%
% date: 2023-5-15
% author: CHEN Yuanzhi
%
%%%%%%%%%%%%%%%%%%

% file param:
Frequency = ["Low","High"];
P_pattern = ["const", "tooth", "sin", "square","noise"];
F_pattern = ["const", "tooth", "sin", "square","noise"];
% Rtcp_use = 0;
% Reverse = 1;
% dxfFile='Drawing3.dxf';
% i=1;j=1;h=1;

% Rtcp_use = 1;
% Reverse = 0;
% dxfFile='Drawing4.dxf';
% i=3;j=5;h=2;
% 
Rtcp_use = 1;
Reverse = 1;
dxfFile='Drawing6.dxf';
i=5;j=3;h=1;
skip=0;
shift=1200;

% printing process param
pwr = 150; % 1.2KW / 4kw *1000;
pFeedrate = 400; % mm/min
lenPos = 800;
flowL = 250; % 6 L/min / 20L/min * 1000;
speedL = 100;% 2 r/min / 10r/min * 1000;
flowR = 400;% 6 L/min / 20L/min * 1000;
speedR = 100;% 2 r/min / 10r/min * 1000;
safetyHeight = 25;
lyrNum=20;
lyrHeight=0.5;
size=0.45;% 0.3为step进行调整
xOffset=-15;
yOffset=15;
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
[pPathSeq,pwrSeq, pFeedrateSeq,~] = handle.genPrintingPath(pwr, pFeedrate, traverse, P_pattern(i), F_pattern(j), Rtcp_use, dxfFile, skip, Reverse, Frequency(h));

% tmpPathSeq=pPathSeq(4:end-2,:);
% tmppwrSeq=pwrSeq(4:end-2,:);
% tmpFeedrateSeq=pFeedrateSeq(4:end-2,:);
% pPathSeq=[];pwrSeq=[];pFeedrateSeq=[];
% lyrPathSeq=tmpPathSeq;
% lyrpwrSeq=tmppwrSeq;
% lyrFeedrateSeq=tmpFeedrateSeq;
% for i=1:lyrNum
%     leadInVec=lyrPathSeq(2,:)-lyrPathSeq(1,:);
%     leadOutVec=lyrPathSeq(end,:)-lyrPathSeq(end-1,:);
%     pPathSeq=[pPathSeq;lyrPathSeq(1,:)-leadInVec*200;...
%         lyrPathSeq(1,:)-leadInVec;lyrPathSeq;lyrPathSeq(end,:)+leadOutVec*200;...
%         lyrPathSeq(end,:)+leadOutVec];
%     pwrSeq=[pwrSeq;0;0;lyrpwrSeq;0;0];
%     pFeedrateSeq=[pFeedrateSeq;lyrFeedrateSeq(1,:);lyrFeedrateSeq(1,:);...
%         lyrFeedrateSeq;lyrFeedrateSeq(end,:);lyrFeedrateSeq(end,:)];
%     
%     tmpPathSeq=[tmpPathSeq(shift:end,:);tmpPathSeq(shift-1:-1:1,:)];
%     tmpPathSeq(:,3)=tmpPathSeq(:,3)+lyrHeight;
%     tmppwrSeq=[tmppwrSeq(shift:end,:);tmppwrSeq(shift-1:-1:1,:)];
%     tmpFeedrateSeq=[tmpFeedrateSeq(shift:end,:);tmpFeedrateSeq(shift-1:-1:1,:)];
%     lyrPathSeq=flipud(tmpPathSeq);
%     lyrpwrSeq=flipud(tmppwrSeq);
%     lyrFeedrateSeq=flipud(tmpFeedrateSeq);
% end

%% 正方形打印的速度调节
% powerOffest=[linspace(0,0,500)';linspace(150,0,500)'];
% pFeedrateSeq=pFeedrateSeq(4:end-2,:);
% pFeedrateSeq(3501:4500,:)=pFeedrateSeq(3501:4500,:)+powerOffest;
% pFeedrateSeq(7501:8500,:)=pFeedrateSeq(7501:8500,:)+powerOffest;
% pFeedrateSeq(11501:12500,:)=pFeedrateSeq(11501:12500,:)+powerOffest;
% %pFeedrateSeq(15500:end,:)=pFeedrateSeq(15500:end,:)+linspace(0,150,499)';
% pFeedrateSeq(1:500,:)=pFeedrateSeq(1:500,:)+linspace(150,0,500)';
% pFeedrateSeq(4001:8000,:)=pFeedrateSeq(4001:8000,:)*1.1;
% pFeedrateSeq(8001:12000,:)=pFeedrateSeq(8001:12000,:)*1.25;
% pFeedrateSeq = repmat(pFeedrateSeq, lyrNum, 1);
% pFeedrateSeq = repmat(pFeedrateSeq(4:end-2,:), lyrNum, 1);

pPathSeq = repmat(pPathSeq(4:end-2,:), lyrNum, 1);
pwrSeq = repmat(pwrSeq(4:end-2,:), lyrNum, 1);%%螺旋线叠加
pPathSeq(:,3)=linspace(0,(lyrNum-1)*lyrHeight,length(pPathSeq(:,3)));%%修改高度
pPathSeq(:,1:2)=pPathSeq(:,1:2)*size;
pPathSeq(:,1)=pPathSeq(:,1)+xOffset;
pPathSeq(:,2)=pPathSeq(:,2)+yOffset;
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
pg.draw_ = true;
pg.drawPath(pPathSeq, pPathSeq);
%% end the script
pg.closeScript();