%%%%%%%%%%%%%%%%%%%
%
% date: 2023-4-24
% author: CHEN Yuanzhi
%
%%%%%%%%%%%%%%%%%%

% file param:
hFilename = strcat('./doubleMaterial',date,'.txt');

% printing process param
aupwr = 220; % 1.2KW / 4kw *1000;
auFeedrate = 675; % mm/min
mapwr = 210;
maFeedrate = 625; % mm/min
ammode=2; %0:au,1:ma,2:mix
lenPos = 900;
flowL = 250; % 6 L/min / 20L/min * 1000;
speedL = 100;% 2 r/min / 10r/min * 1000;
flowR = 400;% 6 L/min / 20L/min * 1000;
speedR = 100;% 2 r/min / 10r/min * 1000;
step = 0.7;
angle = 0:180:359; 
angle=0;
tilte=0;
startCtr = [-40,-20];
pLyrNum = 1;
lyrHeight = 0.6;
cubeShape = [20,16];

% machining process param
mFeedrate = 1400; % mm/min
spindleSpeed = 10000;
toolNum = 4;
toolRadiu = 3;
machiningLyrThickness = 0.1;

%  geometry param
tol = 0.01;
safetyHeight = min(230, 2*pLyrNum*lyrHeight+20);
zOffset = 0;

rotation = true;
side = 1; % machining inside is -1 and outside is 1
wallOffset = -0.5;
allPath=[];
ausPath=[];
masPath=[];
% shape
handle = rotationalZigzagPathCube;

%%
%%%%%%%%%%%%%% printing path
%%%% the regular code for generate a script
pg = cPathGen(hFilename); % create the path generator object
pg.genNewScript();
pg.changeMode(1); % change to printing mode
aus=true; 
if(ammode==0)
    aus=true; 
elseif(ammode==1)
    aus=false;
end
if(ammode==2)
    for i=1:2*pLyrNum
        if(aus)
           pwr=aupwr;
           pFeedrate=auFeedrate;
        else
            pwr=mapwr;
            pFeedrate=maFeedrate;
        end
        [pPathSeq,~,pwrSeq,feedOffset] = handle.genPrintingPath(cubeShape, startCtr, 1, lyrHeight, round(max(100,(1-0.2/2/pLyrNum*i)*pwr)), zOffset+floor((i-1)/2)*lyrHeight, angle(rem(floor((i-1)/2),length(angle))+1), false,tilte, step, aus, ammode);
        lenPosSeq = ones(length(pPathSeq),1) * lenPos;
        if aus
%            pPathSeq = flipud(pPathSeq); 
%            pwrSeq = flipud(pwrSeq);
           ausPath=[ausPath;pPathSeq];
        else
           masPath=[masPath;pPathSeq];
        end
        %%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%
        %%% start printing mode
        pg.setLaser(0, lenPos, flowL, aus*speedL, flowR, (~aus)*speedR); % set a init process param (in case of overshoot)
        pg.saftyToPt([nan, nan, safetyHeight], pPathSeq(1,:), 3000); % safety move the start pt
        pg.pauseProgram();% pause and wait for start (the button)
        pg.enableLaser(3, 10);
        %%% add path pts
        pg.addPathPtsWithPwr(pPathSeq, pwrSeq, lenPosSeq, pFeedrate*feedOffset);
        %%% exist printing mode
        pg.disableLaser(3);
        aus=~aus;
        allPath = [allPath;pPathSeq];
    end
else
    for i=1:pLyrNum
        if(aus)
           pwr=aupwr;
           pFeedrate=auFeedrate;
        else
            pwr=mapwr;
            pFeedrate=maFeedrate;
        end
        [pPathSeq,pwrSeq,feedOffset] = handle.genPrintingPath(cubeShape, startCtr, 1, lyrHeight, round(max(100,(1-0.2/pLyrNum*i)*pwr)), zOffset+(i-1)*lyrHeight, angle(rem(i-1,length(angle))+1), false, step, aus, ammode);
        lenPosSeq = ones(length(pPathSeq),1) * lenPos;
        %%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%
        %%% start printing mode
        pg.setLaser(0, lenPos, flowL, aus*speedL, flowR, (~aus)*speedR); % set a init process param (in case of overshoot)
        pg.saftyToPt([nan, nan, safetyHeight], pPathSeq(1,:), 3000); % safety move the start pt
        pg.pauseProgram();% pause and wait for start (the button)
        pg.enableLaser(3, 10);
        %%% add path pts
        pg.addPathPtsWithPwr(pPathSeq, pwrSeq, lenPosSeq, pFeedrate*feedOffset);
        %%% exist printing mode
        pg.disableLaser(3);
        allPath = [allPath;pPathSeq];
    end    
end
plot3(ausPath(:,1),ausPath(:,2),ausPath(:,3),'r');
hold on
plot3(masPath(:,1),masPath(:,2),masPath(:,3),'b');

%%%%%%%%%%%%% machining path
% safetyHeight = 230;
% mPathSeq = planarMachining([startCtr(1)+cubeShape(1)/2, startCtr(2)+cubeShape(2)/2], [zOffset+pLyrNum*lyrHeight+3, zOffset+pLyrNum*lyrHeight], cubeShape, machiningLyrThickness, toolRadiu);
% pg.changeMode(2); % change to machining mode
% pg.changeTool(toolNum);
% pg.saftyToPt([nan, nan, safetyHeight], [startCtr(1) - toolRadiu - wallOffset - 5, startCtr(2) - toolRadiu - wallOffset - 5, 2 * pLyrNum * lyrHeight], 3000); % safety move the start pt
% pg.pauseProgram();% pause and wait for start (the button)
% pg.enableSpindle(spindleSpeed, toolNum); % set a init process param (in case of overshoot)
% %% add path pts
% pg.addPathPts(mPathSeq, mFeedrate);
% %% exist machining mode
% pg.disableSpindle();
% pg.returnToSafety(safetyHeight, 3000);
% 
% mPathSeq = handle.genMachiningPath(cubeShape, startCtr, pLyrNum*lyrHeight, 2*lyrHeight, toolRadiu, wallOffset, zOffset);
% %% start machining mode
% pg.changeMode(2); % change to machining mode
% pg.changeTool(toolNum);
% pg.saftyToPt([nan, nan, safetyHeight], [startCtr(1) - toolRadiu - wallOffset - 5, startCtr(2) - toolRadiu - wallOffset - 5, 2 * pLyrNum * lyrHeight], 3000); % safety move the start pt
% pg.pauseProgram();% pause and wait for start (the button)
% pg.enableSpindle(spindleSpeed, toolNum); % set a init process param (in case of overshoot)
% %% add path pts
% pg.addPathPts(mPathSeq, mFeedrate);
% %% exist machining mode
% pg.disableSpindle();
% pg.returnToSafety(safetyHeight, 3000);

%% end the script
pg.closeScript();
% pg.draw_ = true;
% pg.drawPath(mPathSeq,mPathSeq);

