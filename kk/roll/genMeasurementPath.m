clear;clc;
% Z=[120;160;200;240;280;310];
filename = strcat('./rollMeasurement_',date,'.txt');
% heightSeq = [120;160;200;240;280;310];
heightSeq=[160;200;240;280];
ptsPerCycle = 360;
measuresPerCycle = 12;
rollRadius=45;
bAgl = 90;
seekDist= 20;

data = genRollMeasurementPts(heightSeq, ptsPerCycle, measuresPerCycle, rollRadius, bAgl, seekDist);
RTCP = 1;
probeMeansureGcodes_v2(data, RTCP, filename)


function data = genRollMeasurementPts(zPosSeq, ptsPerCycle, measuresPerCycle, rollR, bAgl, seekDist)


data=[];
% num=ptsPerCycle;
% radius=45;
% seek=seekDist;
jump = round(ptsPerCycle/measuresPerCycle);
for i=1:length(zPosSeq)
    step=360/ptsPerCycle;
    for j=1:ptsPerCycle
        if rem(j,jump)==0
            label=1; % this is a measure point
        else
            label=0; % this is not a measure point
        end
        curPt = [rollR*cos(step*j*pi/180), rollR*sin(step*j*pi/180), zPosSeq(i), bAgl, step*j]; % (x,y,z,b,c)
        surfNormal = [cos(step*j*pi/180), sin(step*j*pi/180)]; %(x,y), z is assumed always zero.
        data=[data; curPt, label, -seekDist*surfNormal, 0];

%         data=[data;;radius*cos(angle*j*pi/180),radius*sin(angle*j*pi/180),Z(i),90,angle*j,label,-seek*cos(angle*j*pi/180),-seek*sin(angle*j*pi/180),0];
    end
end

end







