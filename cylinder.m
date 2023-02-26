% date: 20230226
% test for alternative hybrid manufactuing a cylinder
% author: Xiaoke DENG


% file param:
pFilename = './cylinderTest0226.txt';
mFilename = './cylinderTestMachinig0226.txt';

% process param
% pwr = 300; % 1.2KW / 4kw *1000;
% lenPos = 900;
% flowL = 300; % 6 L/min / 20L/min * 1000;
% speedL = 200;% 2 r/min / 10r/min * 1000;
% flowR = 300;% 6 L/min / 20L/min * 1000;
% speedR = 200;% 2 r/min / 10r/min * 1000;
% feedrate = 760; % mm/min

% support process param
pwr = 300; % 1.2KW / 4kw *1000;
lenPos = 900;
flowL = 300; % 6 L/min / 20L/min * 1000;
speedL = 250;% 2 r/min / 10r/min * 1000;
flowR = 300;% 6 L/min / 20L/min * 1000;
speedR = 250;% 2 r/min / 10r/min * 1000;
feedrate = 720; % mm/min

%  geometry param
startCtr = [0,40];
% inclinationAgl = 0; % degree
lyrNum = 20;
lyrHeight = 0.5;
wpH = lyrNum * lyrHeight;
radius = 20;
tol = 0.1;

%%
%%%%%%%%%%%%%% printing path
[pPathSeq,pwrSeq] = genCylinderPrintingPath(radius, startCtr, tol, wpH, lyrHeight, pwr);
% generate the sequence for pwr / lenPos
lenPosSeq = ones(length(pPathSeq),1) * lenPos;
% pwrSeq = ones(length(pathSeq),1) * pwr;



%%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%

pg = cPathGen(pFilename); % create the path generator object
pg.openFile();  % open the file

% the regular code for DED
pg.recordGenTime();
pg.closeDoor(); % close door
pg.changeMode(1); % change to printing mode
pg.setLaser(300, 900, flowL, speedL, flowR, speedR); % set a init process param (in case of overshoot)

pg.saftyToPt([nan, nan, 200], [startCtr(1) + radius + 5, startCtr(2), 0], 3000); % safety move the start pt
pg.pauseProgram();% pause and wait for start (the button)
pg.enableLaser(1, 10);

ret = pg.addPathPtsWithPwr(pPathSeq, pwrSeq, lenPosSeq, feedrate);

pg.disableLaser(1);
pg.openDoor();
pg.endProgram();

pg.closeFile();

plot3(pPathSeq(:,1),pPathSeq(:,2),pPathSeq(:,3))
axis equal


%%
%%%%%%%%%%%%%% machining path


mFeedrate = 1000; % mm/min
toolRadiu = 4;
wallOffset = 0.2;

mPathSeq = genCylinderMachiningPath(radius, startCtr, tol, wpH, lyrHeight, toolRadiu, wallOffset);


%%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%

% the regular code for DED
pg = cPathGen(mFilename); % create the path generator object
pg.openFile();  % open the file
pg.recordGenTime();
pg.closeDoor(); % close door
pg.changeMode(2); % change to printing mode

pg.changeTool(1);
pg.saftyToPt([nan, nan, 200], [startCtr(1) - 5, startCtr(2), wpH], 3000); % safety move the start pt
pg.pauseProgram();% pause and wait for start (the button)
pg.enableSpindle(10000,1); % set a init process param (in case of overshoot)


ret = pg.addPathPts(mPathSeq, mFeedrate);
ret 

pg.disableSpindle();
pg.addCmd("G01 Z200 F3000 ;;̧������ȫƽ��");
pg.openDoor();
pg.endProgram();

pg.closeFile();

figure(2)
plot3(mPathSeq(:,1),mPathSeq(:,2),mPathSeq(:,3))
axis equal


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [path,pwrSeq] = genCylinderPrintingPath(cylinderR, startCenter, tol, wpHeight, lyrThickness, pwr)
    % planar circle path

    lyrPtNum = floor(2 * cylinderR * pi / tol)+1;
    % wpHeight = lyrNum * lyrHeight;
    lyrNum = floor(wpHeight/lyrThickness) + 1;
    lyrHeight = wpHeight/lyrNum;
    aglStep = 2 * pi / lyrPtNum;    

    pPathSeq = [];
    pwrSeq = [];
    for lyrIdx = 1:lyrNum    
    %     centerXOffset = ((lyrIdx - 1) * lyrHeight) * tan(inclinationAgl/180 * pi); 
        for j = 1 : lyrPtNum
    %         x = cos(aglStep * j) * radius + startCenter(1) + centerXOffset;
            x = cos(aglStep * j) * cylinderR + startCenter(1);
            y = sin(aglStep * j) * cylinderR + startCenter(2);
            z = (lyrIdx - 1) * lyrHeight;
            pPathSeq = [pPathSeq; x,y,z];
            pwrSeq = [pwrSeq; pwr];
        end
        pwrSeq(end) = 0;
        pPathSeq = [pPathSeq; x,y,z + lyrHeight];
        pwrSeq = [pwrSeq; 0];          
    end

    path = pPathSeq;
end




function path = genCylinderMachiningPath(cylinderR, startCenter, tol, wpHeight, lyrThickness, toolRadiu, wallOffset)
    % planar circle path
    lyrPtNum = floor(2 * cylinderR * pi / tol)+1;
    % wpHeight = lyrNum * lyrHeight;
    lyrNum = floor(wpHeight/lyrThickness) + 1;
    lyrHeight = wpHeight/lyrNum;
    aglStep = 2 * pi / lyrPtNum;
    mPathSeq = [];
    for lyrIdx = 1:lyrNum
    %     centerXOffset = ((lyrIdx - 1) * lyrHeight) * tan(inclinationAgl/180 * pi); 
        for j = 1 : lyrPtNum
    %         x = cos(aglStep * j) * radius + startCenter(1) + centerXOffset;
            x = cos(aglStep * j) * (cylinderR + toolRadiu + wallOffset) + startCenter(1);
            y = sin(aglStep * j) * (cylinderR + toolRadiu + wallOffset) + startCenter(2);
            z = wpHeight - (lyrIdx - 1) * lyrHeight;
            mPathSeq = [mPathSeq; x,y,z];
        end
    end
    path = mPathSeq;
end






