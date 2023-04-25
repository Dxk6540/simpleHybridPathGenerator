%%%%%%%%%%%%%%%%%%%
%
% date: 2023-4-24
% authorï¼? CHEN Yuanzhi
%
%%%%%%%%%%%%%%%%%%

% file param:
hFilename = strcat('./doubleMaterial',date,'.txt');

% printing process param
pwr = 300; % 1.2KW / 4kw *1000;
lenPos = 900;
flowL = 250; % 6 L/min / 20L/min * 1000;
speedL = 100;% 2 r/min / 10r/min * 1000;
flowR = 500;% 6 L/min / 20L/min * 1000;
speedR = 100;% 2 r/min / 10r/min * 1000;
pFeedrate = 700; % mm/min
step = 1;

% machining process param
mFeedrate = 1400; % mm/min
spindleSpeed = 10000;
toolNum = 1;
toolRadiu = 4;

%  geometry param
startCtr = [-60,30];
pLyrNum = 40;
lyrHeight = 0.5;
cubeShape = [20,20];
tol = 0.01;
safetyHeight = 230;
zOffset = 0;
angle = 15;
rotation = true;
side = 1; % machining inside is -1 and outside is 1
wallOffset = 1.1;
aus = true;

% shape
handle = rotationalZigzagPathCube;

%%
%%%%%%%%%%%%%% printing path
%%%% the regular code for generate a script
pg = cPathGen(hFilename); % create the path generator object
pg.genNewScript();
pg.changeMode(1); % change to printing mode
for i=1:2*pLyrNum
    aus=~aus;
    [pPathSeq,pwrSeq,feedOffset] = handle.genPrintingPath(cubeShape, startCtr, 1, lyrHeight, round(max(100,(1-0.2/2/pLyrNum*i)*(pwr-(~aus)*100))), zOffset+floor((i-1)/2)*lyrHeight, angle*floor((i-1)/2), false, step, aus);
    lenPosSeq = ones(length(pPathSeq),1) * lenPos;
    if aus
       flipud(pPathSeq); 
       flipud(pwrSeq);
    end
    %%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%
    %%% start printing mode
    pg.setLaser(pwr, lenPos, flowL, aus*speedL, flowR, (~aus)*speedR); % set a init process param (in case of overshoot)
    pg.saftyToPt([nan, nan, safetyHeight], [startCtr(1), startCtr(2), zOffset+floor((i-1)/2)*lyrHeight], 3000); % safety move the start pt
    pg.pauseProgram();% pause and wait for start (the button)
    pg.enableLaser(3, 10);
    %%% add path pts
    pg.addPathPtsWithPwr(pPathSeq, pwrSeq, lenPosSeq, pFeedrate*feedOffset-(~aus)*200);
    %%% exist printing mode
    pg.disableLaser(3);
    pg.draw_ = true;
    pg.drawPath(pPathSeq, pPathSeq);
end

%%
%%%%%%%%%%%%%% machining path
mPathSeq = handle.genMachiningPath(cubeShape, startCtr, pLyrNum*lyrHeight, lyrHeight, toolRadiu, wallOffset, zOffset);
%%% start machining mode
pg.changeMode(2); % change to machining mode
pg.changeTool(toolNum);
pg.saftyToPt([nan, nan, safetyHeight], [startCtr(1) - toolRadiu - wallOffset - 5, startCtr(2) - toolRadiu - wallOffset - 5, pLyrNum * lyrHeight], 3000); % safety move the start pt
pg.pauseProgram();% pause and wait for start (the button)
pg.enableSpindle(spindleSpeed, toolNum); % set a init process param (in case of overshoot)
%%% add path pts
pg.addPathPts(mPathSeq, mFeedrate);
%%% exist machining mode
pg.disableSpindle();
pg.returnToSafety(safetyHeight, 3000);
%%% end the script
pg.closeScript();
pg.draw_ = true;
pg.drawPath(mPathSeq,mPathSeq);

