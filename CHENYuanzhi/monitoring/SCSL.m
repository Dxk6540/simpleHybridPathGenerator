%%%%%%%%%%%%%%%%%%%
%
% date: 2023-5-15
% author: CHEN Yuanzhi
%
%%%%%%%%%%%%%%%%%%

% file param:
frequency = 9;%1，3，6，9
high = 1.2;%0.8，1，1.2
hFilename = strcat('./SCSL_',num2str(frequency),'_',num2str(high),'.txt');

% printing process param
pwr = 200*high; % 1.2KW / 4kw *1000;
pFeedrate = 400*high; % mm/min
lenPos = 900;
flowL = 250; % 6 L/min / 20L/min * 1000;
speedL = 100;% 2 r/min / 10r/min * 1000;
flowR = 400;% 6 L/min / 20L/min * 1000;
speedR = 100;% 2 r/min / 10r/min * 1000;
safetyHeight = 25;

%  geometry param
traverse=1000;
% shape
handle = singlechannelsinglelayer;

%%
%%%%%%%%%%%%%% printing path
%%%% the regular code for generate a script
pg = cPathGen(hFilename); % create the path generator object
pg.genNewScript();
%%% Beam1
pg.changeMode(1); % change to printing mode
[pPathSeq,pwrSeq, pFeedrateSeq] = handle.genPrintingPath(pwr, pFeedrate, traverse, frequency);
lenPosSeq = ones(length(pPathSeq),1) * lenPos;
%%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%
%%% start printing mode
pg.setLaser(0, lenPos, flowL, speedL, flowR, speedR); % set a init process param (in case of overshoot)
pg.addPathPts([0,0,safetyHeight,0,0], 3000);
pg.addPathPts([0,0,safetyHeight,0,0], 3000);
pg.saftyToPt([nan, nan, safetyHeight], pPathSeq(1,:), 3000); % safety move the start pt
pg.enableLaser(1, 5);
%%% add path pts
pg.addPathPtsWithPwr(pPathSeq, pwrSeq, lenPosSeq, pFeedrateSeq);
%%% exist printing mode
pg.disableLaser(1);

%%% draw
pg.draw_ = true;
pg.drawPath(pPathSeq, pPathSeq);
%% end the script
pg.closeScript();