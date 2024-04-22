function [t_v_d_seq,v_d_seq,feedSeq] = interpolateBetweenTwoPos(vs,Splan_visible,Tplan_visible)
%% Interpolate the Gcodes where two distant adjacent positions have different feed rates
%% Input: pos_v----two positions with different speeds, acc----the specified feed rate
%% Output: pathSeq----the interpolated pos-v, acc----if the specified feed rate is not suitable, choose a larger one in the permitted range
%% Initial parameter

minDist=0.005; %% Unit: mm.0.002 mm - 0.01 mm is okay.
tStep=0.0001; % Unit: s. 0.0001 s = 0.1 ms
v1=vs(1);
v2=vs(2);
acc=100;
if v1>v2
    acc=-100;
end
%% Convolution smooth paras
kernelNum=376;
kernel=1/kernelNum*ones(kernelNum,1);
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
%     tSeq=tSeq+kernelNum*tStep/2; % Add the compensatory distance  可以删除的代�?

%% 4. Recombine the time-feedrate sequence
t_v_seq=[tSeq,feedSeq];
if (tSeq(end)<t+kernelNum*tStep-tStep/100)
    t_v_seq(end+1,:)=[t+kernelNum*tStep,v2];
end
dSeq=zeros(size(t_v_seq,1),1);
dSeq(1)=0;
for i=2:size(t_v_seq,1)
    delta_d=abs((t_v_seq(i,2)+t_v_seq(i-1,2)))/2*(t_v_seq(i,1)-t_v_seq(i-1,1));
    dSeq(i)=dSeq(i-1)+delta_d;
end
t_v_d_seq=[t_v_seq,dSeq];
if Splan_visible
    figure('Name','S-shaped speed curve');
    subplot(2,1,1);
    plot(t_v_d_seq(:,1), t_v_d_seq(:,2));
    xlabel('Time [s]');
    ylabel('Speed [mm/s]');
    subplot(2,1,2);
    plot(t_v_d_seq(:,end), t_v_d_seq(:,2));
    xlabel('Distance [mm]');
    ylabel('Speed [mm/s]');
end
clear t_v_seq posSeq delta_d tSeq i;
%% 5. t-v curve -> pos-v interpolation
dSeq=[];
accumulatedDist=0;
while accumulatedDist<max(t_v_d_seq(:,3))
    dSeq=[dSeq;accumulatedDist];
    accumulatedDist=accumulatedDist+minDist;
end
% posSeq + t_v_pos_d_seq ----> vSeq
vSeq=zeros(length(dSeq),1);
for i=1:length(dSeq)
    d_index=find(t_v_d_seq(:,end)>dSeq(i),1);
    if isempty(d_index)
        if i==length(dSeq)
            vSeq(i)=t_v_d_seq(end,2);
        end
        break;
    elseif d_index-1<1
        vSeq(i)=t_v_d_seq(d_index,2);
    end
    ratio=(t_v_d_seq(d_index,end)-dSeq(i))/(t_v_d_seq(d_index,end)-t_v_d_seq(d_index-1,end));% according to the distance ratio
    vSeq(i)=t_v_d_seq(d_index,2)-(t_v_d_seq(d_index,2)-t_v_d_seq(d_index-1,2))*ratio;
end
if t_v_d_seq(end,end)>dSeq(end)
    dSeq=[dSeq;dSeq(end)+minDist];
    vSeq=[vSeq;t_v_d_seq(end,2)];
end
v_d_seq=[vSeq,dSeq];
%% 7. Draw
if Tplan_visible
    figure('Name','t,d,v acc=400 mm/s^2');
    subplot(1,3,1)
    plot(t_v_d_seq(:,1),t_v_d_seq(:,2),'Marker','*','Color','blue');
    xlabel('time [s]');
    ylabel('feed rate [mm/s]');
    title('v - t');
    subplot(1,3,2)
    plot(t_v_d_seq(:,1),t_v_d_seq(:,end),'Marker','*','Color','blue');
    xlabel('time [s]');
    ylabel('distance [mm]');
    title('d - t');
    subplot(1,3,3)
    plot(t_v_d_seq(:,end),t_v_d_seq(:,2),'Marker','*','Color','blue');
    hold on
    plot(v_d_seq(:,end),v_d_seq(:,1),'Marker','o');
    xlabel('distance [mm]');
    ylabel('feed rate [mm/s]');
    title('v - d');
    legend('Equal time interval (0.001 s)','Equal distance interval (0.005 mm)');
end
%% 8. Output the T plan results
% pathSeq=v_d_seq(:,1:3);
feedSeq=v_d_seq(:,1);
clear accumulatedDist d_index i posSeq ratio requiredAcc t transitionDist vSeq;
end