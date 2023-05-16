% file param:
hFilename = strcat('./MediaMold',date,'.txt');

% printing process param
pwr = 175; % 1.2KW / 4kw *1000;
lenPos = 900;
flowL = 250; % 6 L/min / 20L/min * 1000;
speedL = 100;% 2 r/min / 10r/min * 1000;
flowR = 400;% 6 L/min / 20L/min * 1000;
speedR = 0;% 2 r/min / 10r/min * 1000;
pFeedrate = 600; % mm/min
step = 1.3;
channel = 3;

% machining process param
mFeedrate = 30; % mm/min
spindleSpeed = 10000;
toolNum = 1;
toolRadiu = 1;
machiningLyrThickness = 0.1;
planarMachiningDepth = 1.5;

%  geometry param
startCtr = [-60,-50];
pLyrNum = 10;
lyrHeight = 0.2;
radius = 3.45;
tol = 0.01;
safetyHeight = 230;
zOffset = 0;
side = 1; % machining inside is -1 and outside is 1
outterWallOffsetRng = [0.8, 0];
innerWallOffsetRng = [radius-1, radius-1.025];
sglWpHeight = pLyrNum * lyrHeight;
alterNum = 3;
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
    [pPathSeq, pwrSeq, feedOffset] = handle.genPrintingPath(radius, startCtr, tol, pLyrNum+1, lyrHeight, ...
                                        pwr, zOffset, channel, step);
    lenPosSeq = ones(length(pPathSeq),1) * lenPos;
    pg.setLaser(0, lenPos, flowL, speedL, flowR, speedR); % set a init process param (in case of overshoot)
    pg.saftyToPt([nan, nan, safetyHeight], pPathSeq(1,:), 3000); % safety move the start pt
    pg.pauseProgram();% pause and wait for start (the button)
    pg.enableLaser(1, 10);
    %%% add path pts
    pg.addPathPtsWithPwr(pPathSeq, pwrSeq, lenPosSeq, pFeedrate);
    %%% exist printing mode
    pg.disableLaser(1);
    pg.draw_ = false;
    pg.drawPath(pPathSeq, pPathSeq);
    allPath = [allPath;pPathSeq];
    
    %%%%%%%%%%%%%%%%%%%%% plannar circle machining %%%%%%%%%%%%%%%%%%%%
    pg.addCmd(";;;;;start a planar machining process");
    depthRng = [sglWpHeight+zOffset+planarMachiningDepth, sglWpHeight+zOffset];
    mFeedrate = 300;
    toolNum = 3;
    toolRadiu = 5;
    [mpPath, mpFeedSeq] = planarCircleMachining(startCtr, depthRng, [0,3], -machiningLyrThickness, toolRadiu, mFeedrate, mFeedrate);   
    pg.changeMode(2); % change to machining mode
    pg.changeTool(toolNum);
    pg.saftyToPt([nan, nan, safetyHeight], [startCtr(1), startCtr(2), zOffset + pLyrNum * lyrHeight + 5], 3000); % safety move the start pt
    pg.pauseProgram();% pause and wait for start (the button)
    pg.enableSpindle(spindleSpeed, toolNum); % set a init process param (in case of overshoot)
    %%% add path pts
    pg.addPathPts(mpPath, mpFeedSeq);
    %%% exist machining mode
    pg.disableSpindle();
    pg.returnToSafety(safetyHeight, 3000);
    
    %%%%%%%%%%%%%%%%%%%%%%%% gen outter machining process %%%%%%%%%%%%%%%%%%%%%%%
%     pg.addCmd(";;;;;start an outter machining process");    
%     side = 1;
%     totalMachiningPath = [];
%     toolNum = 3;
%     toolRadiu = 5;
%     for wallOffset = outterWallOffsetRng(1) : -machiningLyrThickness : outterWallOffsetRng(2)
%         mPathSeq = handle.genMachiningPath(radius, startCtr, tol, pLyrNum * lyrHeight, lyrHeight, toolRadiu, wallOffset, zOffset, side);
%         totalMachiningPath = [totalMachiningPath; mPathSeq]; 
%     end
%     pg.changeTool(toolNum);
%     pg.saftyToPt([nan, nan, safetyHeight], [startCtr(1)+toolRadiu+radius+wallOffset+5, startCtr(2)+toolRadiu+radius+wallOffset+5, zOffset + pLyrNum * lyrHeight + 5], 3000); % safety move the start pt
%     pg.pauseProgram();% pause and wait for start (the button)
%     pg.enableSpindle(spindleSpeed, toolNum); % set a init process param (in case of overshoot)
%     %% add path pts
%     pg.addPathPts(totalMachiningPath, mFeedrate);
%     %% exist machining mode
%     pg.disableSpindle();
%     pg.returnToSafety(safetyHeight, 3000);

    
    %%%%%%%%%%%%%%%%%%%%%%%% gen inner machining process %%%%%%%%%%%%%%%%%%%%%%%
%     pg.addCmd(";;;;;start an inner machining process");
%     mFeedrate = 15;
%     side = -1;
%     totalMachiningPath = [];
%     toolNum = 1;
%     toolRadiu = 1;
%     for wallOffset = innerWallOffsetRng
%         mPathSeq = handle.genMachiningPath(radius, startCtr, tol, pLyrNum * lyrHeight, lyrHeight, toolRadiu, wallOffset, zOffset, side);
%         totalMachiningPath = [totalMachiningPath; mPathSeq]; 
%     end
%     pg.changeTool(toolNum);
%     pg.saftyToPt([nan, nan, safetyHeight], [startCtr(1), startCtr(2), zOffset + pLyrNum * lyrHeight + 5], 3000); % safety move the start pt
%     pg.pauseProgram();% pause and wait for start (the button)
%     pg.enableSpindle(spindleSpeed, toolNum); % set a init process param (in case of overshoot)
%     %% add path pts
%     pg.addPathPts(totalMachiningPath, mFeedrate);
%     %% exist machining mode
%     pg.returnToSafety(zOffset + pLyrNum * lyrHeight + 5, 3000);
%     pg.disableSpindle();
%     pg.returnToSafety(safetyHeight, 3000);        
end
pg.draw_ = true;
pg.drawPath(allPath, allPath);
%%% end the script
pg.closeScript();