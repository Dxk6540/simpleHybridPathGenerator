function [dSeq,vSeq] = tvd_dv(tvd,step,maxLength,show)
%% Calculate the tv
dSeq=[];
accumulatedDist=0;
while accumulatedDist<max(tvd(:,3))&&accumulatedDist<=maxLength+0.001
    dSeq=[dSeq;accumulatedDist];
    accumulatedDist=accumulatedDist+step;
end
% posSeq + t_v_pos_d_seq ----> vSeq
vSeq=zeros(length(dSeq),1);
for i=1:length(dSeq)
    d_index=find(tvd(:,end)>dSeq(i),1);
    if isempty(d_index)
        if i==length(dSeq)
            vSeq(i)=tvd(end,2);
        end
        break;
    elseif d_index-1<1
        vSeq(i)=tvd(d_index,2);
    end
    ratio=(tvd(d_index,end)-dSeq(i))/(tvd(d_index,end)-tvd(d_index-1,end));% according to the distance ratio
    vSeq(i)=tvd(d_index,2)-(tvd(d_index,2)-tvd(d_index-1,2))*ratio;
end
if(show)
    figure('Name','v-d');
    plot(dSeq,vSeq);
%     ylim([10,13.4]);
end
end

