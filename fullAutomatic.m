% file param:
pFilename = strcat('./fullAutoCylinderTest',date,'.txt');
mFilename = strcat('./fullAutoCylinderMachineTest',date,'.txt');

% printing process param
pwr = 300; % 1.2KW / 4kw *1000;
lenPos = 900;
flowL = 250; % 6 L/min / 20L/min * 1000;
speedL = 100;% 2 r/min / 10r/min * 1000;
flowR = 250;% 6 L/min / 20L/min * 1000;
speedR = 100;% 2 r/min / 10r/min * 1000;
pFeedrate = 600; % mm/min
channel = 2;
step = 1;

% machining process param
mFeedrate = 800; % mm/min
spindleSpeed = 10000;
toolNum = 1;
toolRadiu = 4;
wallOffset = 1.1;
side = 1; % machining inside is -1 and outside is 1

%  geometry param
startCtr = [0,0];
% inclinationAgl = 0; % degree
pLyrNum = 20;
% wpH = 10;
lyrHeight = 0.5;
radius = 20;
tol = 0.1;
safetyHeight = 230;
zOffset = 0;

% shape
handle=cylinder;


%%
%%%%%%%%%%%%%% printing path
[pPathSeq,pwrSeq] = handle.genPrintingPath(radius, startCtr, tol, pLyrNum, lyrHeight, pwr, zOffset, channel, step);
pg = cPathGen(pFilename); % create the path generator object
pg.genNewScript();
genPrintingProcess(pg, safetyHeight, pPathSeq, pwrSeq, pFeedrate);
pg.closeScript();


%%
%%%%%%%%%%%%%% machining path
mPathSeq = handle.genMachiningPath(radius, startCtr, tol, pLyrNum * lyrHeight, lyrHeight, toolRadiu, wallOffset, zOffset, side);
%%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%
%%%% the regular code for generate a script
pg = cPathGen(mFilename); % create the path generator object
pg.genNewScript();
genMachiningProcess(pg, safetyHeight, toolNum, mPathSeq, mFeedrate);
%%% end the script
pg.closeScript();



%%% draw the path
pg.drawPath(pPathSeq, mPathSeq);


