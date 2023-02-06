centerX = 0; %中心X坐标
centerY = 0; %中心Y坐标
radius = 20; %半径
step = 1.5; % 通道间距
alpha = 0; %悬垂角
reverse = false; % 正反转
def = 0.1; %插值误差
skip = 2/def; %缺口大小
n = round(1.0 / def * 2 * pi * radius); %插值点个数
orient = 1; %转动方向
angle = 2 * pi / n;
A = [NaN,NaN,200;
    centerX + radius + 5,centerY,NaN;
    NaN,NaN,0];
    P=[];
for i = 0:19 
    Temp=[];
    radius = radius + 0.5 * sin(alpha / 180 * pi);
    for j = 0:n-1
        x = cos(angle * j);
        y = sin(angle * j);
        Temp = [Temp;x,y,0]; %插值点"
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


