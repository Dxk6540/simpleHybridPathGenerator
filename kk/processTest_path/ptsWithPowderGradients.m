function [pts_eachLayer] = ptsWithPowderGradients(paras)
%%
EDR=paras(1);
EMS=paras(2);
layerHeight=paras(3);
layerNum=paras(4);
powderMode_0=paras(5:6);
powderMode_1=paras(7:8);
laserMelting=paras(9);
mixPowderFor1stLayer=paras(10);
if(mixPowderFor1stLayer)
    t = linspace(0, 1, layerNum+1);
    powderMode_eachLayer = (1-t).' * powderMode_0 + t.' * powderMode_1;
    powderMode_eachLayer(1,:)=[];
else
    t = linspace(0, 1, layerNum);
    powderMode_eachLayer = (1-t).' * powderMode_0 + t.' * powderMode_1;
end
pts_eachLayer=[];
for i=1:layerNum
    if(laserMelting&&i==1)
        pts_eachLayer=[pts_eachLayer;EDR,EMS,layerHeight*(i-1),[0 0]];
    elseif(laserMelting==2)
        pts_eachLayer=[pts_eachLayer;EDR,EMS,layerHeight*(i-1),[0 0]];
    elseif(laserMelting==3)
        pts_eachLayer=[pts_eachLayer;EDR,EMS,layerHeight*(i-1),[0 0]];
    end
    pts_eachLayer=[pts_eachLayer;EDR,EMS,layerHeight*(i-1),powderMode_eachLayer(i,:)];
    if i==layerNum&&laserMelting==3
        pts_eachLayer=[pts_eachLayer;EDR,EMS,layerHeight*i,[0 0]];
    end
end
end