
% file param:
filename = './supportTestV2.txt';


% process param
pwr = 300; % 1.2KW / 4kw *1000;
lenPos = 900;
flowL = 300; % 6 L/min / 20L/min * 1000;
speedL = 200;% 2 r/min / 10r/min * 1000;
flowR = 300;% 6 L/min / 20L/min * 1000;
speedR = 200;% 2 r/min / 10r/min * 1000;
feedrate = 760; % mm/min

%  geometry param
startCenter = [50,50];
inclinationAgl = 30; % degree
lyrNum = 40;
lyrHeight = 0.5;
radius = 3;
tol = 0.3;


% planar circle path
lyrPtNum = floor(2 * radius * pi / tol)+1;
aglStep = 2 * pi / lyrPtNum;
pathSeq = [];
for lyrIdx = 1:lyrNum
    centerXOffset = ((lyrIdx - 1) * lyrHeight) * tan(inclinationAgl/180 * pi); 
    for j = 1 : lyrPtNum
        x = cos(aglStep * j) + startCenter(1) + centerXOffset;
        y = sin(aglStep * j) + startCenter(2);
        z = (lyrIdx - 1) * lyrHeight;
        pathSeq = [pathSeq; x,y,z];
    end        
end

% generate the sequence for pwr / lenPos
lenPosSeq = ones(length(pathSeq),1) * lenPos;
pwrSeq = ones(length(pathSeq),1) * 300;







%%%%%%%%%%%%% following for path Gen %%%%%%%%%%%%%%%%%%%%%

pg = cPathGen(filename); % create the path generator object
pg.openFile();  % open the file

% the regular code for DED
pg.closeDoor(); % close door
pg.changeMode(1); % change to printing mode
pg.setLaser(300, 900, 250, 100, 250, 100); % set a init process param (in case of overshoot)

pg.saftyToPt([nan, nan, 200], [startCenter(1) - 5, startCenter(2), 0], 3000); % safety move the start pt
pg.pauseProgram();% pause and wait for start (the button)
pg.enableLaser(1, 10);


ret = pg.addPathPtsWithPwr(pathSeq, pwrSeq, lenPosSeq, feedrate);
ret 

pg.disableLaser(1);
pg.openDoor();
pg.endProgram();

pg.closeFile();

plot3(pathSeq(:,1),pathSeq(:,2),pathSeq(:,3))
axis equal


