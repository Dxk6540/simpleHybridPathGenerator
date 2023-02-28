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

% printing process param
pwr = 300; % 1.2KW / 4kw *1000;
lenPos = 900;
flowL = 300; % 6 L/min / 20L/min * 1000;
speedL = 250;% 2 r/min / 10r/min * 1000;
flowR = 300;% 6 L/min / 20L/min * 1000;
speedR = 250;% 2 r/min / 10r/min * 1000;
pFeedrate = 720; % mm/min

% machining process param
mFeedrate = 1000; % mm/min
spindleSpeed = 10000;
toolNum = 1;
toolRadiu = 4;
wallOffset = 1.9;

%  geometry param
startCtr = [0,40];
% inclinationAgl = 0; % degree
pLyrNum = 20;
% wpH = 10;
lyrHeight = 0.5;
radius = 20;
tol = 0.1;
safetyHeight = 230;
zOffset = 0;

%%
%%%%%%%%%%%%%% printing path
[pPathSeq,pwrSeq] = genCylinderPrintingPath(radius, startCtr, tol, pLyrNum, lyrHeight, pwr, zOffset);
% generate the sequence for pwr / lenPos
lenPosSeq = ones(length(pPathSeq),1) * lenPos;

%%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%
%%%% the regular code for generate a script
pg = cPathGen(pFilename); % create the path generator object
pg.openFile();  % open the file
pg.recordGenTime();
pg.closeDoor(); % close door

%%% start printing mode
pg.changeMode(1); % change to printing mode
pg.setLaser(pwr, lenPos, flowL, speedL, flowR, speedR); % set a init process param (in case of overshoot)
pg.saftyToPt([nan, nan, safetyHeight], [startCtr(1) + radius + 5, startCtr(2), 0], 3000); % safety move the start pt
pg.pauseProgram();% pause and wait for start (the button)
pg.enableLaser(1, 10);

%%% add path pts
ret = pg.addPathPtsWithPwr(pPathSeq, pwrSeq, lenPosSeq, pFeedrate);

%%% exist printing mode
pg.disableLaser(1);

%%% end the script
pg.openDoor();
pg.endProgram();
pg.closeFile();

plot3(pPathSeq(:,1),pPathSeq(:,2),pPathSeq(:,3))
axis equal


%%
%%%%%%%%%%%%%% machining path
mPathSeq = genCylinderMachiningPath(radius, startCtr, tol, pLyrNum * lyrHeight, lyrHeight, toolRadiu, wallOffset, zOffset);

%%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%
%%%% the regular code for generate a script
pg = cPathGen(mFilename); % create the path generator object
pg.openFile();  % open the file
pg.recordGenTime();
pg.closeDoor(); % close door

%%% start machining mode
pg.changeMode(2); % change to printing mode
pg.changeTool(toolNum);
pg.saftyToPt([nan, nan, safetyHeight], [startCtr(1) - 5, startCtr(2), wpH], 3000); % safety move the start pt
pg.pauseProgram();% pause and wait for start (the button)
pg.enableSpindle(spindleSpeed, toolNum); % set a init process param (in case of overshoot)

%%% add path pts
ret = pg.addPathPts(mPathSeq, mFeedrate);
ret 

%%% exist machining mode
pg.disableSpindle();
% pg.addCmd("G01 Z200 F3000 ;;抬刀至安全平面");
% pg.saftyToPt([nan, nan, safetyHeight], [startCtr(1) - 5, startCtr(2), safetyHeight], 3000); % safety move the start pt
pg.returnToSafety(220, 3000);

%%% end the script
pg.openDoor();
pg.endProgram();
pg.closeFile();

%%% draw the path
figure(2)
plot3(mPathSeq(:,1),mPathSeq(:,2),mPathSeq(:,3))
axis equal














%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% function [path,pwrSeq] = genCylinderPrintingPath(cylinderR, startCenter, tol, wpHeight, lyrThickness, pwr, zOffset)
%     % planar circle path
% 
%     lyrPtNum = floor(2 * cylinderR * pi / tol)+1;
%     % wpHeight = lyrNum * lyrHeight;
%     if floor(wpHeight/lyrThickness) == wpHeight/lyrThickness
%         lyrNum = floor(wpHeight/lyrThickness);            
%     else
%         lyrNum = floor(wpHeight/lyrThickness) + 1;    
%     end
% 
%     lyrHeight = wpHeight/lyrNum;
%     aglStep = 2 * pi / lyrPtNum;    
% 
%     pPathSeq = [];
%     pwrSeq = [];
%     for lyrIdx = 1:lyrNum    
%     %     centerXOffset = ((lyrIdx - 1) * lyrHeight) * tan(inclinationAgl/180 * pi); 
%         for j = 1 : lyrPtNum
%     %         x = cos(aglStep * j) * radius + startCenter(1) + centerXOffset;
%             x = cos(aglStep * j) * cylinderR + startCenter(1);
%             y = sin(aglStep * j) * cylinderR + startCenter(2);
%             z = (lyrIdx - 1) * lyrHeight + zOffset;
%             pPathSeq = [pPathSeq; x,y,z];
%             pwrSeq = [pwrSeq; pwr];
%         end
% %         pwrSeq(end) = 0;
%         % stop the power when lift the tool 
%         pPathSeq = [pPathSeq; x,y,z];
%         pwrSeq = [pwrSeq; 0];     
%         pPathSeq = [pPathSeq; x,y,z + lyrHeight];
%         pwrSeq = [pwrSeq; 0];          
%     end
% 
%     path = pPathSeq;
% end

% function path = genCylinderMachiningPath(cylinderR, startCenter, tol, wpHeight, lyrThickness, toolRadiu, wallOffset)
%     % planar circle path
%     lyrPtNum = floor(2 * cylinderR * pi / tol)+1;
%     % wpHeight = lyrNum * lyrHeight;
%     if floor(wpHeight/lyrThickness) == wpHeight/lyrThickness
%         lyrNum = floor(wpHeight/lyrThickness);            
%     else
%         lyrNum = floor(wpHeight/lyrThickness) + 1;    
%     end
%     lyrHeight = wpHeight/lyrNum;
%     aglStep = 2 * pi / lyrPtNum;
%     mPathSeq = [];
%     for lyrIdx = 1:lyrNum
%     %     centerXOffset = ((lyrIdx - 1) * lyrHeight) * tan(inclinationAgl/180 * pi); 
%         for j = 1 : lyrPtNum
%     %         x = cos(aglStep * j) * radius + startCenter(1) + centerXOffset;
%             x = cos(aglStep * j) * (cylinderR + toolRadiu + wallOffset) + startCenter(1);
%             y = sin(aglStep * j) * (cylinderR + toolRadiu + wallOffset) + startCenter(2);
%             z = wpHeight - (lyrIdx - 1) * lyrHeight;
%             mPathSeq = [mPathSeq; x,y,z];
%         end
%     end
%     path = mPathSeq;
% end




function [path,pwrSeq] = genCylinderPrintingPath(cylinderR, startCenter, tol, lyrNum, lyrThickness, pwr, zOffset)
    % planar circle path

    lyrPtNum = floor(2 * cylinderR * pi / tol)+1;
%     % wpHeight = lyrNum * lyrHeight;
%     if floor(wpHeight/lyrThickness) == wpHeight/lyrThickness
%         lyrNum = floor(wpHeight/lyrThickness);            
%     else
%         lyrNum = floor(wpHeight/lyrThickness) + 1;    
%     end
%     lyrHeight = wpHeight/lyrNum;
    lyrHeight = lyrThickness;
    aglStep = 2 * pi / lyrPtNum;    

    pPathSeq = [];
    pwrSeq = [];
    for lyrIdx = 1:lyrNum    
    %     centerXOffset = ((lyrIdx - 1) * lyrHeight) * tan(inclinationAgl/180 * pi); 
        for j = 1 : lyrPtNum
    %         x = cos(aglStep * j) * radius + startCenter(1) + centerXOffset;
            x = cos(aglStep * j) * cylinderR + startCenter(1);
            y = sin(aglStep * j) * cylinderR + startCenter(2);
            z = (lyrIdx - 1) * lyrHeight + zOffset;
            pPathSeq = [pPathSeq; x,y,z];
            pwrSeq = [pwrSeq; pwr];
        end
%         pwrSeq(end) = 0;
        % stop the power when lift the tool 
%         pPathSeq = [pPathSeq; x,y,z];
%         pwrSeq = [pwrSeq; 0];     
%         pPathSeq = [pPathSeq; x,y,z + lyrHeight];
%         pwrSeq = [pwrSeq; 0];          
    end

    path = pPathSeq;
end



function path = genCylinderMachiningPath(cylinderR, startCenter, tol, wpHeight, lyrThickness, toolRadiu, wallOffset, zOffset)
    % planar circle path
    lyrPtNum = floor(2 * (cylinderR + toolRadiu + wallOffset) * pi / tol)+1;
    % wpHeight = lyrNum * lyrHeight;
    if floor(wpHeight/lyrThickness) == wpHeight/lyrThickness
        lyrNum = floor(wpHeight/lyrThickness);            
    else
        lyrNum = floor(wpHeight/lyrThickness) + 1;    
    end
    lyrHeight = wpHeight/lyrNum;

    if zOffset > 0
        lyrNum = lyrNum + 2;
    end
    
    aglStep = 2 * pi / lyrPtNum;
    mPathSeq = [];
    for lyrIdx = 1:lyrNum
    %     centerXOffset = ((lyrIdx - 1) * lyrHeight) * tan(inclinationAgl/180 * pi); 
        for j = 1 : lyrPtNum
    %         x = cos(aglStep * j) * radius + startCenter(1) + centerXOffset;
            x = cos(aglStep * j) * (cylinderR + toolRadiu + wallOffset) + startCenter(1);
            y = sin(aglStep * j) * (cylinderR + toolRadiu + wallOffset) + startCenter(2);
            z = wpHeight - (lyrIdx - 1) * lyrHeight + zOffset;
            mPathSeq = [mPathSeq; x,y,z];
        end
    end
    path = mPathSeq;
end






