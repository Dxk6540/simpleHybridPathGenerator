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
Rtcp_use = 0;
Reverse = 1;
dxfFile='Drawing8.dxf';
i=1;j=1;h=1;

% Rtcp_use = 1;
% Reverse = 0;
% dxfFile='Drawing4.dxf';
% i=3;j=5;h=2;
% 
% Rtcp_use = 1;
% Reverse = 1;
% dxfFile='Drawing6.dxf';
% i=5;j=3;h=1;
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
size=1.15;

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
tmpPathSeq=pPathSeq(4:end-2,:);
tmppwrSeq=pwrSeq(4:end-2,:);
tmpFeedrateSeq=pFeedrateSeq(4:end-2,:);
pPathSeq=[];pwrSeq=[];pFeedrateSeq=[];
lyrPathSeq=tmpPathSeq;
lyrpwrSeq=tmppwrSeq;
lyrFeedrateSeq=tmpFeedrateSeq;
for i=1:lyrNum
    leadInVec=lyrPathSeq(2,:)-lyrPathSeq(1,:);
    leadOutVec=lyrPathSeq(end,:)-lyrPathSeq(end-1,:);
    pPathSeq=[pPathSeq;lyrPathSeq(1,:)-leadInVec*200;...
        lyrPathSeq(1,:)-leadInVec;lyrPathSeq;lyrPathSeq(end,:)+leadOutVec*200;...
        lyrPathSeq(end,:)+leadOutVec];
    pwrSeq=[pwrSeq;0;0;lyrpwrSeq;0;0];
    pFeedrateSeq=[pFeedrateSeq;lyrFeedrateSeq(1,:);lyrFeedrateSeq(1,:);...
        lyrFeedrateSeq;lyrFeedrateSeq(end,:);lyrFeedrateSeq(end,:)];
    
    tmpPathSeq=[tmpPathSeq(shift:end,:);tmpPathSeq(1:shift-1,:)];
    tmpPathSeq(:,3)=tmpPathSeq(:,3)+lyrHeight;
    tmppwrSeq=[tmppwrSeq(shift:end,:);tmppwrSeq(1:shift-1,:)];
    tmpFeedrateSeq=[tmpFeedrateSeq(shift:end,:);tmpFeedrateSeq(1:shift-1,:)];
    
    lyrPathSeq=flipud(tmpPathSeq);
    lyrpwrSeq=flipud(tmppwrSeq);
    lyrFeedrateSeq=flipud(tmpFeedrateSeq);
end
pPathSeq(:,1:2)=pPathSeq(:,1:2)*size;
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