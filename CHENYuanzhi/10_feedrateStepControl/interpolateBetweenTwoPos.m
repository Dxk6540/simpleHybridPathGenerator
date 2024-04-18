function [t_v_pos_d_seq,pathSeq,feedSeq,acc,pos_v_d_seq] = interpolateBetweenTwoPos(pos_v,acc,smooth,Tplan_visible,Splan_visible)
%% Interpolate the Gcodes where two distant adjacent positions have different feed rates
%% Input: pos_v----two positions with different speeds, acc----the specified feed rate
%% Output: pathSeq----the interpolated pos-v, acc----if the specified feed rate is not suitable, choose a larger one in the permitted range
%% Initial parameter
maxAcc=200; %% Unit: mm/s^2.
minDist=0.005; %% Unit: mm.0.002 mm - 0.01 mm is okay.
tStep=0.0001; % Unit: s. 0.0001 s = 0.1 ms
v1=pos_v(1,end);
v2=pos_v(2,end);
dist=sqrt(sum((pos_v(2,1:3)-pos_v(1,1:3)).^2));
% Convolution smooth paras
kernelNum=376;
kernel=1/kernelNum*ones(kernelNum,1);
% transitionDist=(kernelNum/2*tStep*v1)+kernelNum/2*tStep*v2;
transitionDist=kernelNum*tStep*v2;
%% 1. Check the necessarity for interpolation. 2. Check if the acceleration is suitable. If not, change to a larger one.
requiredAcc=abs((v2^2-v1^2))/2/(dist-transitionDist);
if requiredAcc<=0||requiredAcc>maxAcc
    fprintf('\nAlert! The machine cannot follow the required feed rate change. The required acceleration is %.4f mm/s^2\n',requiredAcc);
    fprintf('Position: %.4f, %.4f, %.4f ----> %.4f, %.4f, %.4f\n',pos_v(1,1),pos_v(1,2),pos_v(1,3),pos_v(2,1),pos_v(2,2),pos_v(2,3));
    pathSeq=pos_v(:,1:3);
    feedSeq=pos_v(:,4);
    acc=-1;
    pos_v_d_seq=-1;
    t_v_pos_d_seq=-1;
    return; % Quit the function
elseif requiredAcc>acc
    fprintf('\nExceed the defined acceleration: %d, the required acceleration is: %.4f\n',acc,requiredAcc);
    fprintf('Position: %.4f, %.4f, %.4f ----> %.4f, %.4f, %.4f\n',pos_v(1,1),pos_v(1,2),pos_v(1,3),pos_v(2,1),pos_v(2,2),pos_v(2,3));
    acc=requiredAcc;
end
if v2<v1
    acc=-acc;
end
%% 2. t-v curve
t = (v2-v1)/acc;
tSeq=(0:tStep:t)';
t_v_seq=[tSeq,linspace(v1,(v1+acc*tSeq(end)),length(tSeq))'];
if tSeq(end)<t-tStep/100
    t_v_seq(end+1,:)=[t,v2];
end
clear tSeq;
%% 3. S interpolation plan
feedSeq=t_v_seq(:,2);
tSeq=t_v_seq(:,1);
if(smooth)
    if tSeq(end)-tSeq(end-1)<tStep % if the last point is far away from the penultimate point
        tSeq(end)=[];
        feedSeq(end)=[];
    end
    for i=1:(kernelNum) % prepare for convolution
        tSeq=[tSeq(1)-tStep;tSeq];
        feedSeq=[feedSeq(1);feedSeq];
        tSeq=[tSeq;tSeq(end)+tStep];
        feedSeq=[feedSeq;feedSeq(end)];
    end
    feedSeq=conv(feedSeq,kernel,'same');% convolution
    tSeq(1:kernelNum/2)=[]; % delete the extra points
    tSeq(end-(kernelNum/2-1):end)=[];
    feedSeq(1:kernelNum/2)=[];
    feedSeq(end-(kernelNum/2-1):end)=[];
    while abs(feedSeq(1)-feedSeq(2))<0.000001 % delete the repeated points
        feedSeq(1)=[];
        tSeq(1)=[];
    end
    while abs(feedSeq(end)-feedSeq(end-1))<0.000001 % delete the repeated points
        feedSeq(end)=[];
        tSeq(end)=[];
    end
    if(tSeq(1)<0)
        tSeq=tSeq-tSeq(1);
    end
    %     tSeq=tSeq+kernelNum*tStep/2; % Add the compensatory distance  可以删除的代码
end
%% 4. Recombine the time-feedrate sequence
t_v_seq=[tSeq,feedSeq];
if smooth&&(tSeq(end)<t+kernelNum*tStep-tStep/100)
    t_v_seq(end+1,:)=[t+kernelNum*tStep,v2];
end
posSeq=zeros(size(t_v_seq,1),3);
dSeq=zeros(size(t_v_seq,1),1);
unitVector=(pos_v(2,1:3)-pos_v(1,1:3))/norm(pos_v(2,1:3)-pos_v(1,1:3));% Directional unit vector
posSeq(1,:)=pos_v(1,1:3);
dSeq(1)=0;
for i=2:size(t_v_seq,1)
    delta_d=abs((t_v_seq(i,2)+t_v_seq(i-1,2)))/2*(t_v_seq(i,1)-t_v_seq(i-1,1));
    posSeq(i,:)=posSeq(i-1,1:3)+delta_d*unitVector;
    dSeq(i)=dSeq(i-1)+delta_d;
end
t_v_pos_d_seq=[t_v_seq,posSeq,dSeq];
if(t_v_pos_d_seq(end)>dist)
    t_v_pos_d_seq(end,:)=[];
end
if Splan_visible
    figure('Name','S-shaped speed curve');
    subplot(2,1,1);
    plot(t_v_pos_d_seq(:,1), t_v_pos_d_seq(:,2));
    xlabel('Time [s]');
    ylabel('Speed [mm/s]');
    subplot(2,1,2);
    plot(t_v_pos_d_seq(:,end), t_v_pos_d_seq(:,2));
    xlabel('Distance [mm]');
    ylabel('Speed [mm/s]');
end
clear t_v_seq posSeq delta_d tSeq i;
%% 5. t-v curve -> pos-v interpolation
posSeq=[];
dSeq=[];
accumulatedDist=0;
while accumulatedDist<max(t_v_pos_d_seq(:,6))
    dSeq=[dSeq;accumulatedDist];
    posSeq=[posSeq;pos_v(1,1:3)+accumulatedDist*unitVector];
    accumulatedDist=accumulatedDist+minDist;
end
% posSeq + t_v_pos_d_seq ----> vSeq
vSeq=zeros(length(dSeq),1);
for i=1:length(dSeq)
    d_index=find(t_v_pos_d_seq(:,end)>dSeq(i),1);
    if isempty(d_index)
        if i==length(dSeq)
            vSeq(i)=t_v_pos_d_seq(end,2);
        end
        break;
    elseif d_index-1<1
        vSeq(i)=t_v_pos_d_seq(d_index,2);
    end
    ratio=(t_v_pos_d_seq(d_index,end)-dSeq(i))/(t_v_pos_d_seq(d_index,end)-t_v_pos_d_seq(d_index-1,end));% according to the distance ratio
    vSeq(i)=t_v_pos_d_seq(d_index,2)-(t_v_pos_d_seq(d_index,2)-t_v_pos_d_seq(d_index-1,2))*ratio;
end
if t_v_pos_d_seq(end,6)>dSeq(end)&&dist-t_v_pos_d_seq(end,6)>minDist
    dSeq=[dSeq;dSeq(end)+minDist];
    posSeq=[posSeq;pos_v(1,1:3)+dSeq(end)*unitVector];
    vSeq=[vSeq;t_v_pos_d_seq(end,2)];
end
pos_v_d_seq=[posSeq,vSeq,dSeq];
%% 6. Merge to the final path sequence
if(abs(pos_v_d_seq(end,4)-pos_v(2,4))>0.00001)
    pos_v_d_seq=[pos_v_d_seq;[pos_v(2,:),dist]];
end
%% 7. Draw
if Tplan_visible
    figure('Name','t,d,v acc=400 mm/s^2');
    subplot(1,3,1)
    plot(t_v_pos_d_seq(:,1),t_v_pos_d_seq(:,2),'Marker','*','Color','blue',LineWidth=1);
    xlabel('time [s]');
    ylabel('feed rate [mm/s]');
    title('v - t');
    subplot(1,3,2)
    plot(t_v_pos_d_seq(:,1),t_v_pos_d_seq(:,6),'Marker','*','Color','blue',LineWidth=1);
    xlabel('time [s]');
    ylabel('distance [mm]');
    title('d - t');
    subplot(1,3,3)
    plot(t_v_pos_d_seq(:,6),t_v_pos_d_seq(:,2),'Marker','*','Color','blue',LineWidth=1);
    hold on
    plot(pos_v_d_seq(:,5),pos_v_d_seq(:,4),'Marker','o',LineWidth=0.5);
    xlabel('distance [mm]');
    ylabel('feed rate [mm/s]');
    title('v - d');
    legend('Equal time interval (0.001 s)','Equal distance interval (0.005 mm)');
end
%% 8. Output the T plan results
if(sum(abs(pos_v_d_seq(end,1:3)-pos_v(2,1:3)))>0.01)
    pos_v_d_seq=[pos_v_d_seq;[pos_v(2,:),dist]];
end
pathSeq=pos_v_d_seq(:,1:3);
feedSeq=pos_v_d_seq(:,4);
clear accumulatedDist d_index i posSeq ratio requiredAcc t transitionDist vSeq;
end