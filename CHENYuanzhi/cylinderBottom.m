% file param:
hFilename = strcat('./CylinderFixing',date,'.txt');

% printing process param
pwr = 200; % 1.2KW / 4kw *1000;
lenPos = 900;
flowL = 0; % 6 L/min / 20L/min * 1000;
speedL = 0;% 2 r/min / 10r/min * 1000;
flowR = 250;% 6 L/min / 20L/min * 1000;
speedR = 100;% 2 r/min / 10r/min * 1000;
pFeedrate = 600; % mm/min
step = 0.8;
channel = 2;

% machining process param
mFeedrate = 30; % mm/min
spindleSpeed = 10000;
toolNum = 1;
toolRadiu = 1;
machiningLyrThickness = 0.1;
planarMachiningDepth = 3;

%  geometry param
startCtr = [0,00];
pLyrNum = 20;
lyrHeight = 0.5;
radius = 70;
tol = 0.1;
safetyHeight = 230;
zOffset = 0;
side = 1; % machining inside is -1 and outside is 1
outterWallOffsetRng = [0.8, 0];
innerWallOffsetRng = [radius-1, radius-1.025];
sglWpHeight = pLyrNum * lyrHeight;
alterNum = 0;
zOffsetRng = [zOffset, zOffset + sglWpHeight*alterNum]; 
allPath=[];

% shape
handle = hollowCylinder;

%%
%%%%%%%%%%%%%% printing path
%%%% the regular code for generate a script
pg = cPathGen(hFilename); % create the path generator object
pg.genNewScript();

for zOffset = zOffsetRng(1): sglWpHeight: zOffsetRng(2)
    %%%%%%% gen printing process %%%%%%
    pg.addCmd(";;;;;start a printing process;;;;;;;;;;");
    pg.changeMode(1);
    [pPathSeq, pwrSeq, feedOffset] = handle.genPrintingPath(radius, startCtr, tol, pLyrNum, lyrHeight, ...
                                        pwr, zOffset, channel, step,3,3,0);
    lenPosSeq = ones(length(pPathSeq),1) * lenPos;
    pg.setLaser(0, lenPos, flowL, speedL, flowR, speedR); % set a init process param (in case of overshoot)
    pg.startRTCP(safetyHeight, 16);
    pg.saftyToPt([nan, nan, safetyHeight], pPathSeq(1,:), 3000); % safety move the start pt
    pg.pauseProgram();% pause and wait for start (the button)
    pg.enableLaser(2, 5);
    %%% add path pts
    pg.addPathPtsWithPwr(pPathSeq, pwrSeq, lenPosSeq, pFeedrate);
    %%% exist printing mode
    pg.disableLaser(2);
    pg.stopRTCP(safetyHeight, 16);  
    pg.draw_ = false;
    pg.drawPath(pPathSeq, pPathSeq);
    allPath = [allPath;pPathSeq];
end
%%% end the script
pg.closeScript();