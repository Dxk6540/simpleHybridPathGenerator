% file param:
filename = strcat('./digitalTwin',date,'.txt');

% printing process param
pwr = 300; % 1.2KW / 4kw *1000;
lenPos = 900;
flowL = 250; % 6 L/min / 20L/min * 1000;
speedL = 100;% 2 r/min / 10r/min * 1000;
flowR = 250;% 6 L/min / 20L/min * 1000;
speedR = 100;% 2 r/min / 10r/min * 1000;
pFeedrate = 620; % mm/min(cylinder 600, vase 590)
channel = 2;
step = 1;

%  geometry param
startCtr = [0,0];
% inclinationAgl = 0; % degree
pLyrNum = 30;
lyrHeight = 0.5;
radius = 20;
tol = 0.1;
safetyHeight = 200;
    
%%
pg = cPathGen(filename); % create the path generator object
pg.genNewScript();
pg.draw_ = false;
pg.experiment_ = false;
for lyrIdx = 0 : pLyrNum
     [printPathSeq,pwrSeq,feedrateOffset] = cylinder.genPrintingPath(radius, startCtr, tol, 1, lyrHeight, pwr, lyrIdx*lyrHeight, channel, step);
     genPrintingProcess(pg, safetyHeight, printPathSeq, pwrSeq, pFeedrate*feedrateOffset);
     pg.addPathPt(startCtr(1)-50,startCtr(2),safetyHeight-50);
     pg.pauseProgramMust();
end

pg.closeScript();