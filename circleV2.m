centerX = 0; %中心X坐标
centerY = 0; %中心Y坐标
radius = 20; %半径
step = 1.5; % 通道间距
alpha = 0; %悬垂�?
reverse = false; % 正反�?
def = 0.1; %插�?�误�?
skip = 2/def; %缺口大小
n = round(1.0 / def * 2 * pi * radius); %插�?�点个数
orient = 1; %转动方向
angle = 2 * pi / n;
% A = [NaN,NaN,200;
%     centerX + radius + 5,centerY,NaN;
%     NaN,NaN,0];
    P=[];
for i = 0:19 
    Temp=[];
    radius = radius + 0.5 * sin(alpha / 180 * pi);
    for j = 0:n-1
        x = cos(angle * j);
        y = sin(angle * j);
        Temp = [Temp;x,y,0]; %插�?�点"
    end
    P=[P;repmat([centerX,centerY,0.5*i],n-skip,1)+radius*Temp(1:n-skip,:)];
    if (step>0)
        radius=radius+step; 
        Temp=flipud(Temp);
        P=[P; repmat([centerX,centerY,0.5*i],n-skip,1)+radius*Temp(1:n-skip,:)];
        radius=radius-step;
    end
    if (reverse==true)
        orient=-orient;
    end
end




% following for path Gen
safetyP =  A;
result = P;
pg = cPathGen('./circlePath.txt');
pg.openFile();

pg.closeDoor();

pg.changeMode(1);
pg.setLaser(300, 900, 250, 100, 250, 100);

pg.saftyToPt([nan, nan, 200], [centerX + radius + 5, centerY, 0], 3000);
pg.pauseProgram();
pg.enableLaser(1, 10);

% pts = zeros(100,3);
% for i = 1:100
%     pts(i,:) = [i, i*2,i*3];
% end

pg.addPathPts(P, 600);

pg.disableLaser(1);
pg.openDoor();
pg.endProgram();


pg.closeFile();









