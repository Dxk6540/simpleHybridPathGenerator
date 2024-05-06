clear;clc;
Z=[120;160;200;240;280;310];
data=[];
num=360;
radius=45;
seek=20;
for i=1:length(Z)
    angle=360/num;
    for j=1:num
        if rem(j,30)==0
            label=1;
        else
            label=0;
        end
        data=[data;radius*cos(angle*j*pi/180),radius*sin(angle*j*pi/180),Z(i),90,angle*j,label,-seek*cos(angle*j*pi/180),-seek*sin(angle*j*pi/180),0];
    end
end