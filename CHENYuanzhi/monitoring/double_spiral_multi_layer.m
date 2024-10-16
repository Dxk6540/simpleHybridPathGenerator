%%%%%%%%%%%%%%%%%%%
%
% date: 2023-5-15
% author: CHEN Yuanzhi
%
%%%%%%%%%%%%%%%%%%

% file param:
P_pattern = ["const", "tooth", "sin","noise"];
F_pattern = ["const", "tooth", "sin","noise"];
% printing process param
pwr = 200; % 1.2KW / 4kw *1000;
pFeedrate = 600; % mm/min
lenPos = 800;
flowL = 250; % 6 L/min / 20L/min * 1000;
speedL = 100;% 2 r/min / 10r/min * 1000;
flowR = 400;% 6 L/min / 20L/min * 1000;
speedR = 100;% 2 r/min / 10r/min * 1000;
safetyHeight = 35;
traverse=2000;

B_axis=randB(2*length(P_pattern)*length(F_pattern));
% shape
handle = doublespiralMultiplelayer;
load('Z');
Z_coord=data'*3;
% Z_coord = -0.98*ones(1,8002);
%%
%%%%%%%%%%%%%% printing path
%%%% the regular code for generate a script
i=4;
j=4;
Rtcp_use = [1,1];
hFilename = strcat('./DoubleSpiralMultiLayer_',P_pattern(i),'_',F_pattern(j),'.txt');
pg = cPathGen(hFilename); % create the path generator object
pg.genNewScript();
%%% Beam1
pg.changeMode(1); % change to printing mode

[pPathSeq,pwrSeq, pFeedrateSeq,vertices] = handle.genPrintingPath(pwr, pFeedrate, traverse, P_pattern(i), F_pattern(j), Rtcp_use, B_axis(4*i+j-4,:), Z_coord);
lenPosSeq = ones(length(pPathSeq),1) * lenPos;
%%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%
%%% start printing mode
pg.setLaser(0, lenPos, flowL, speedL, flowR, speedR); % set a init process param (in case of overshoot)
pg.startRTCP(safetyHeight, 16); 
pg.addPathPts([0,0,safetyHeight,0,0], 3000);
pg.addPathPts([0,0,safetyHeight,pPathSeq(1,4:5)], 3000);
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
saveName=strcat('DoubleSpiralMultiLayer_',P_pattern(i),'_',F_pattern(j),'.mat');
save(saveName,'pPathSeq','pwrSeq','pFeedrateSeq');
%% end the script
pg.closeScript();
save('DoubleSpiralMultiLayer_vertices.mat','vertices');

function B_axis=randB(numbers)
% 设置随机种子
rng(123); % 替换为你希望使用的种子

% 定义可选数字
options = [15, 15, 15, 15, 15];
% options = [0, 0, 0, 0, 0];
% 生成 20 个随机整数
randNumbers = options(randi(length(options), 1, numbers));

B_axis=[randNumbers(1:numbers/2);randNumbers(numbers/2+1:end)]';
end