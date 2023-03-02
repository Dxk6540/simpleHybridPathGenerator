% file param:
pFilename = strcat('./cylinderTest',date,'.txt');
mFilename = strcat('./cylinderTestMachinig',date,'.txt');

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
flowL = 250; % 6 L/min / 20L/min * 1000;
speedL = 100;% 2 r/min / 10r/min * 1000;
flowR = 250;% 6 L/min / 20L/min * 1000;
speedR = 100;% 2 r/min / 10r/min * 1000;
pFeedrate = 600; % mm/min
channel = 2;
step = 1;

% machining process param
mFeedrate = 800; % mm/min
spindleSpeed = 10000;
toolNum = 1;
toolRadiu = 4;
wallOffset = 1.1;
side = 1; % machining inside is -1 and outside is 1

%  geometry param
startCtr = [0,0];
% inclinationAgl = 0; % degree
pLyrNum = 300;
% wpH = 10;
lyrHeight = 0.5;
radius = 20;
tol = 0.1;
safetyHeight = 230;
zOffset = 0;

% shape
handle=vase;


xPos = [];
zPos = [];
pos = [];
tanVec = [];
for curZ = 0:1:150
    curX = handle.genVaseRadius(curZ);
    curTan = handle.getVaseTangent(curZ);
    xPos = [xPos, curX];
    zPos = [zPos, curZ]; 
    pos = [pos; curX, curZ];
    tanVec = [tanVec;curTan];
end

plot(xPos, zPos)
hold on
plot(-xPos, zPos)
hold on
ax = gca;
drawTanVec(ax, pos, tanVec)
% for i = 1:length(tanVec)
%     plot(xPos, zPos)
%     hold on    
% end

axis equal


function drawTanVec(ax, origPos, tanVec)
    tanVecLen  = 40;
    for i = 1:length(tanVec)
        p0 = origPos(i,:);
        curTan = tanVec(i,:); 
        pe = p0 + tanVecLen*curTan;
        plot([p0(1), pe(1)], [p0(2), pe(2)])
        hold on    
    end
end


function getToolRect(pos, vec, toolRad, toolLen)




end

