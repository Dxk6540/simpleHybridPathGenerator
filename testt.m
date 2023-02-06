startX = -40; %起点X坐标
startY = -40; %起点Y坐标
length = 50; %单线长度
skip=20; %缺口长度20
step = 1; % 搭接
alpha = 0; %倾角
height = 0.5; %层高
% feedrate = 760; %进给速度
count = 1; %层数
Path=[]; %路径




for i = 0:count 
    Temp=[startX,startY,height*i;
        startX+length,startY,height*i;
        startX+length+skip,startY,height*i;
        startX+length+length+skip,startY,height*i];
    Path=[Path;Temp];
    if (step>0)
        Temp=flipud(Temp);
        Path=[Path;[0,step,0]+Temp];
    end

end
Power = ones(16,1) * 300;
lenPos = Power;
% feedrate = ones(16,1);
% for i = 1:16 
%     feedrate(i) = i*100;
% end
feedrate = 700;

% following for path Gen
% safetyP =  A;
pg = cPathGen('./circlePathV2Test222.txt');
pg.openFile();

pg.closeDoor();

pg.changeMode(1);
pg.setLaser(300, 900, 250, 100, 250, 100);

pg.saftyToPt([nan, nan, 200], [startX + 5, startY, 0], 3000);
pg.pauseProgram();
pg.enableLaser(1, 10);

% pts = zeros(100,3);
% for i = 1:100
%     pts(i,:) = [i, i*2,i*3];
% end

% pg.addPathPts(Path, feedrate);
pg.addPathPtsWithPwr(Path, Power, lenPos, feedrate);

pg.disableLaser(1);
pg.openDoor();
pg.endProgram();


pg.closeFile();