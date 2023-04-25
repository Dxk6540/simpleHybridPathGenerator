%%%%%%%%%%%%%%%%%%%
%
% date: 2023-4-24
% author: CHEN Yuanzhi
%
%%%%%%%%%%%%%%%%%%

% file param:
hFilename = strcat('./doubleMaterial',date,'.txt');

% printing process param
pwr = 250; % 1.2KW / 4kw *1000;
lenPos = 900;
flowL = 250; % 6 L/min / 20L/min * 1000;
speedL = 100;% 2 r/min / 10r/min * 1000;
flowR = 400;% 6 L/min / 20L/min * 1000;
speedR = 100;% 2 r/min / 10r/min * 1000;
pFeedrate = 500; % mm/min
step = 1;

% machining process param
mFeedrate = 1400; % mm/min
spindleSpeed = 10000;
toolNum = 3;
toolRadiu = 5;
machiningLyrThickness = 0.1;

%  geometry param
startCtr = [20,-100];
pLyrNum = 24;
lyrHeight = 0.48;
cubeShape = [20,20];
tol = 0.01;
safetyHeight = min(230, 2*pLyrNum*lyrHeight+20);
zOffset = 0;
angle = 0:45:359;
rotation = true;
side = 1; % machining inside is -1 and outside is 1
wallOffset = -0.5;
aus = true;
allPath=[];

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
    [pPathSeq,pwrSeq,feedOffset] = handle.genPrintingPath(cubeShape, startCtr, 1, lyrHeight, round(max(100,(1-0.2/2/pLyrNum*i)*(pwr-(~aus)*50))), zOffset+(i-1)*lyrHeight, angle(rem(floor((i-1)/2),length(angle))+1), false, step, aus);
    lenPosSeq = ones(length(pPathSeq),1) * lenPos;
    if aus
       pPathSeq = flipud(pPathSeq); 
       pwrSeq = flipud(pwrSeq);
    end
    %%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%
    %%% start printing mode
    pg.setLaser(0, lenPos, flowL, aus*speedL, flowR, (~aus)*speedR); % set a init process param (in case of overshoot)
    pg.saftyToPt([nan, nan, safetyHeight], pPathSeq(1,:), 3000); % safety move the start pt
    pg.pauseProgram();% pause and wait for start (the button)
    pg.enableLaser(3, 10);
    %%% add path pts
    pg.addPathPtsWithPwr(pPathSeq, pwrSeq, lenPosSeq, pFeedrate*feedOffset-(~aus)*100);
    %%% exist printing mode
    pg.disableLaser(3);
    pg.draw_ = false;
    pg.drawPath(pPathSeq, pPathSeq);
    allPath = [allPath;pPathSeq];
end
pg.draw_ = true;
pg.drawPath(allPath, allPath);

%%
%%%%%%%%%%%%%% machining path
mPathSeq = handle.genMachiningPath(cubeShape, startCtr, 2*pLyrNum*lyrHeight, 2*lyrHeight, toolRadiu, wallOffset, zOffset);
%%% start machining mode
pg.changeMode(2); % change to machining mode
pg.changeTool(toolNum);
pg.saftyToPt([nan, nan, safetyHeight], [startCtr(1) - toolRadiu - wallOffset - 5, startCtr(2) - toolRadiu - wallOffset - 5, 2 * pLyrNum * lyrHeight], 3000); % safety move the start pt
pg.pauseProgram();% pause and wait for start (the button)
pg.enableSpindle(spindleSpeed, toolNum); % set a init process param (in case of overshoot)
%%% add path pts
pg.addPathPts(mPathSeq, mFeedrate);
%%% exist machining mode
pg.disableSpindle();
pg.returnToSafety(safetyHeight, 3000);

mPathSeq = planarMachining([startCtr(1)+cubeShape(1)/2, startCtr(2)+cubeShape(2)/2], [zOffset+2*pLyrNum*lyrHeight+1.5, zOffset+2*pLyrNum*lyrHeight], cubeShape, machiningLyrThickness, toolRadiu);
pg.changeMode(2); % change to machining mode
pg.changeTool(toolNum);
pg.saftyToPt([nan, nan, safetyHeight], [startCtr(1) - toolRadiu - wallOffset - 5, startCtr(2) - toolRadiu - wallOffset - 5, 2 * pLyrNum * lyrHeight], 3000); % safety move the start pt
pg.pauseProgram();% pause and wait for start (the button)
pg.enableSpindle(spindleSpeed, toolNum); % set a init process param (in case of overshoot)
%%% add path pts
pg.addPathPts(mPathSeq, mFeedrate);
%%% exist machining mode
pg.disableSpindle();
pg.returnToSafety(safetyHeight, 3000);

%%% end the script
pg.closeScript();
% pg.draw_ = true;
% pg.drawPath(mPathSeq,mPathSeq);

