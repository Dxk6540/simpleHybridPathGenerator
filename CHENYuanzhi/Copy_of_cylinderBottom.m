% file param:
hFilename = strcat('./CylinderRR',date,'.txt');

% printing process param
pwr = 600; % 1.2KW / 4kw *1000;
lenPos = 20;
flowL = 0; % 6 L/min / 20L/min * 1000;
speedL = 0;% 2 r/min / 10r/min * 1000;
flowR = 300;% 6 L/min / 20L/min * 1000;
speedR = 140;% 2 r/min / 10r/min * 1000;
pFeedrate = 1000; % mm/min
step = 1;
channel = 4;

%  geometry param
startCtr = [0,0];
pLyrNum = 15;
lyrHeight = 0.8;
radius = 40;
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
handle = Copy_of_hollowCylinder;

%%
%%%%%%%%%%%%%% printing path
%%%% the regular code for generate a script
pg = cPathGen(hFilename); % create the path generator object
pg.genNewScript();

mPathSeq = handle.genMachiningPath(radius, startCenter, tol, wpHeight, lyrThickness, toolRadiu, wallOffset, zOffset, side);
%% start machining mode
pg.changeMode(2); % change to machining mode
pg.changeTool(toolNum);
pg.startRTCP(safetyHeight, toolNum);
pg.saftyToPt([nan, nan, safetyHeight], [startCtr(1) - toolRadiu - wallOffset - 5, startCtr(2) - toolRadiu - wallOffset - 5, 2 * pLyrNum * lyrHeight], 3000); % safety move the start pt
pg.pauseProgram();% pause and wait for start (the button)
pg.enableSpindle(spindleSpeed, toolNum); % set a init process param (in case of overshoot)
%% add path pts
pg.addPathPts(mPathSeq, mFeedrate);
%% exist machining mode
pg.stopRTCP(safetyHeight, toolNum); 
pg.returnToSafety(safetyHeight, 3000);
pg.disableSpindle();
%%% end the script
pg.closeScript();