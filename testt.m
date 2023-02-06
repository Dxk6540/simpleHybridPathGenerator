startX = -40; %���X����
startY = -40; %���Y����
length = 50; %���߳���
skip=20; %ȱ�ڳ���20
step = 1; % ���
alpha = 0; %���
height = 0.5; %���
% feedrate = 760; %�����ٶ�
count = 1; %����
Path=[]; %·��




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