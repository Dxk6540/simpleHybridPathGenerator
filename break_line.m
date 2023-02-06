startX = -50; %���X����
startY = -82; %���Y����
Length = 40; %���߳���
skip=20; %ȱ�ڳ���20
step = 1; % ���
alpha = 0; %���
height = 0.5; %���
feedrate = 760; %�����ٶ�
count = 20; %����
Path=[]; %·��
Power = [];
power = 300; %1.2kw
lenPos = 900; %��Ƭλ��
flowL = 300; %6L/min
speedL = 200;%2r/min
flowR = 300;%6L/min
speedR = 200;%2r/min
if(step>0)
    for i = 0:count-1 
        Temp=[startX,startY,height*i;
            startX+Length,startY,height*i;
            startX+Length+0.1,startY,height*i;
            startX+Length+skip-0.1,startY,height*i;
            startX+Length+skip,startY,height*i;
            startX+Length+Length+skip,startY,height*i];
        Path=[Path;Temp];
        Power=[Power;300;200;0;0;200;300];
        Temp=flipud(Temp);
        Path=[Path;[0,step,0]+Temp];
        Power=[Power;300;200;0;0;200;300];
    end
else
    for i = 0:count-1:2 
        Temp=[startX,startY,height*i;
            startX+Length,startY,height*i;
            startX+Length+0.1,startY,height*i;
            startX+Length+skip-0.1,startY,height*i;
            startX+Length+skip,startY,height*i;
            startX+Length+Length+skip,startY,height*i;
            startX+Length+Length+skip,startY,height*(i+1);
            startX+Length+skip,startY,height*(i+1);
            startX+Length+skip-0.1,startY,height*(i+1);
            startX+Length+0.1,startY,height*(i+1);
            startX+Length,startY,height*(i+1);
            startX,startY,height*(i+1)];
        Path=[Path;Temp];
        Power=[Power;300;200;0;0;200;300;300;200;0;0;200;300];
    end
end
lenPos = ones(length(Power),1) * 900;



% following for path Gen
% safetyP =  A;
pg = cPathGen('./breakingLinePathV2.txt');
pg.openFile();

pg.closeDoor();

pg.changeMode(1);
pg.setLaser(300, 900, 250, 100, 250, 100);

pg.saftyToPt([nan, nan, 200], [startX - 5, startY, 0], 3000);
pg.pauseProgram();
pg.enableLaser(1, 10);

% pts = zeros(100,3);
% for i = 1:100
%     pts(i,:) = [i, i*2,i*3];
% end

pg.addPathPtsWithPwr(Path, Power, lenPos, feedrate);

pg.disableLaser(1);
pg.openDoor();
pg.endProgram();


pg.closeFile();