%%%%%%%%%%%%%%%%%%%
%
% date: 2023-4-24
% author: CHEN Yuanzhi
%
%%%%%%%%%%%%%%%%%%

% file param:
hFilename = strcat('./doubleMaterialOrder',date,'.txt');

% printing process param
aupwr = 220; % 1.2KW / 4kw *1000;
auFeedrate = 675; % mm/min
mapwr = 210;
maFeedrate = 625; % mm/min
lenPos = 900;
flowL = 250; % 6 L/min / 20L/min * 1000;
speedL = 100;% 2 r/min / 10r/min * 1000;
flowR = 400;% 6 L/min / 20L/min * 1000;
speedR = 100;% 2 r/min / 10r/min * 1000;
step = 0.8;
aus = true;

% machining process param
mFeedrate = 1400; % mm/min
spindleSpeed = 10000;
toolNum = 4;
toolRadiu = 3;
machiningLyrThickness = 0.1;

%  geometry param
startCtr = [-30,-25];
pLyrNum = 3;
lyrHeight = 0.6;
cubeShape = [20,7];
tol = 0.01;
safetyHeight = min(230, 2*pLyrNum*lyrHeight+20);
zOffset = 0;
angle = 0;
tilte=20;
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
ausPath=[];
masPath=[];
pg.saftyToPt([nan, nan, safetyHeight], [cubeShape,safetyHeight], 3000); % safety move the start pt
pg.startRTCP(safetyHeight,16);
for i=1:2*pLyrNum
    [pPathSeq, bcSeq, pwrSeq,feedOffset] = handle.genPrintingPath(cubeShape, startCtr, 1, lyrHeight,...
        round(max(100,(1-0.2/2/pLyrNum*i)*aupwr)), zOffset+floor((i-1)/2)*lyrHeight,...
        angle(rem(floor((i-1)/2), length(angle))+1), false, tilte, step, 0, 0);
    pPathSeq = [pPathSeq, bcSeq];
    lenPosSeq = ones(length(pPathSeq),1) * lenPos;
    aus=true;
    %%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%
    %%% start printing mode
    for j=0:(size(pPathSeq,1)/4)-1
        pg.saftyToPt([nan, nan, safetyHeight], pPathSeq(4*j+1,:), 3000); % safety move the start pt
        pg.setLaser(0, lenPos, flowL, aus*speedL, flowR, (~aus)*speedR); % set a init process param (in case of overshoot)
        pg.enableLaser(3, 10);
        %%% add path pts
        if(aus)
            offsetPwrCoff=1;
            offsetFeedCoff=1;
            ausPath=[ausPath;pPathSeq(4*j+1:4*j+4,:)];
        else
            offsetPwrCoff=mapwr/aupwr;
            offsetFeedCoff=maFeedrate/auFeedrate;
            masPath=[masPath;pPathSeq(4*j+1:4*j+4,:)];
        end
        pg.addPathPtsWithPwr(pPathSeq(4*j+1:4*j+4,:), round(offsetPwrCoff*pwrSeq(4*j+1:4*j+4)), lenPosSeq(4*j+1:4*j+4), round(offsetFeedCoff*auFeedrate*feedOffset(4*j+1:4*j+4)));
        %%% exist printing mode
        pg.disableLaser(3);
        aus = ~aus;
        safetyHeight=pPathSeq(4*j+1,3);
    end
end
pg.stopRTCP(safetyHeight,16);
plot3(ausPath(:,1),ausPath(:,2),ausPath(:,3),'r');
hold on
plot3(masPath(:,1),masPath(:,2),masPath(:,3),'b');

%%
% %%%%%%%%%%%%%% machining path
safetyHeight = 230;
mPathSeq = planarMachining([startCtr(1)+cubeShape(1)/2, startCtr(2)+cubeShape(2)/2], [zOffset+pLyrNum*lyrHeight+1.5, zOffset+pLyrNum*lyrHeight], cubeShape, machiningLyrThickness, toolRadiu);
pg.changeMode(2); % change to machining mode
pg.changeTool(toolNum);
pg.startRTCP(safetyHeight,toolNum);
pg.saftyToPt([nan, nan, safetyHeight], [startCtr(1) - toolRadiu - wallOffset - 5, startCtr(2) - toolRadiu - wallOffset - 5, pLyrNum * lyrHeight], 3000); % safety move the start pt
pg.pauseProgram();% pause and wait for start (the button)
pg.enableSpindle(spindleSpeed, toolNum); % set a init process param (in case of overshoot)
%%% add path pts
pg.addPathPts(mPathSeq, mFeedrate);
%%% exist machining mode
pg.disableSpindle();
pg.returnToSafety(safetyHeight, 3000);

mPathSeq = handle.genMachiningPath(cubeShape, startCtr, pLyrNum*lyrHeight, 2*lyrHeight, toolRadiu, wallOffset, zOffset);
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
pg.stopRTCP(safetyHeight,toolNum);
pg.returnToSafety(safetyHeight, 3000);

%%% end the script
pg.closeScript();
% pg.draw_ = true;
% pg.drawPath(mPathSeq,mPathSeq);

