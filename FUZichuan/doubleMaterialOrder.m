%%%%%%%%%%%%%%%%%%%
%
% date: 2023-4-24
% author: CHEN Yuanzhi
%
%%%%%%%%%%%%%%%%%%

% file param:
hFilename = strcat('./doubleMaterialOrder',date,'.txt');

% printing process param
aupwr = 250; % 1.2KW / 4kw *1000;
auFeedrate = 600; % mm/min
mapwr = 200;
maFeedrate = 500; % mm/min
lenPos = 900;
flowL = 250; % 6 L/min / 20L/min * 1000;
speedL = 100;% 2 r/min / 10r/min * 1000;
flowR = 400;% 6 L/min / 20L/min * 1000;
speedR = 100;% 2 r/min / 10r/min * 1000;
step = 1;
aus = true;

% machining process param
mFeedrate = 1400; % mm/min
spindleSpeed = 10000;
toolNum = 4;
toolRadiu = 3;
machiningLyrThickness = 0.1;

%  geometry param
startCtr = [60,20];
pLyrNum = 24;
lyrHeight = 0.5;
cubeShape = [20,20];
tol = 0.01;
safetyHeight = min(230, 2*pLyrNum*lyrHeight+20);
zOffset = 0;
angle = 0:30:359;
rotation = true;
side = 1; % machining inside is -1 and outside is 1
wallOffset = -0.5;
allPath=[];

% shape
handle = rotationalZigzagPathCube;

%%
%%%%%%%%%%%%%% printing path
%%%% the regular code for generate a script
pg = cPathGen(hFilename); % create the path generator object
pg.genNewScript();
pg.changeMode(1); % change to printing mode
pg.saftyToPt([nan, nan, safetyHeight], [cubeShape,safetyHeight], 3000); % safety move the start pt
for i=1:2*pLyrNum
    [pPathSeq,pwrSeq,feedOffset] = handle.genPrintingPath(cubeShape, startCtr, 1, lyrHeight, round(max(100,(1-0.2/2/pLyrNum*i)*aupwr)), zOffset+floor((i-1)/2)*lyrHeight, angle(rem(floor((i-1)/2),length(angle))+1), false, step, 0, 0);
    lenPosSeq = ones(length(pPathSeq),1) * lenPos;
    %%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%
    %%% start printing mode
    for j=0:(size(pPathSeq,1)/4)-1
        pg.setLaser(0, lenPos, flowL, aus*speedL, flowR, (~aus)*speedR); % set a init process param (in case of overshoot)
        pg.enableLaser(3, 10);
        %%% add path pts
        if(aus)
            offsetPwrCoff=1;
            offsetFeedCoff=1;
        else
            offsetPwrCoff=mapwr/aupwr;
            offsetFeedCoff=maFeedrate/auFeedrate;
        end
        pg.addPathPtsWithPwr(pPathSeq(4*j+1:4*j+4,:), round(offsetPwrCoff*pwrSeq(4*j+1:4*j+4)), lenPosSeq(4*j+1:4*j+4), round(offsetFeedCoff*auFeedrate*feedOffset(4*j+1:4*j+4)));
        %%% exist printing mode
        pg.disableLaser(3);
        aus = ~aus;
    end
    allPath = [allPath;pPathSeq];
end
pg.draw_ = true;
pg.drawPath(allPath, allPath);

%%
%%%%%%%%%%%%%% machining path
safetyHeight = 230;
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

%%% end the script
pg.closeScript();
% pg.draw_ = true;
% pg.drawPath(mPathSeq,mPathSeq);

