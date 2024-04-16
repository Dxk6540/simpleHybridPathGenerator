clear;clc;
deltaD=2;
% pPathSeq=[0 0 0;10 0 0;10+deltaD 0 0;30 0 0;30+deltaD 0 0;40 0 0];
% feedSeq=[6.6666;6.6666;13.3333;13.3333;6.6666;6.6666];
pPathSeq=[0 0 0;10 0 0;10+deltaD 0 0;20 0 0];
% feedSeq=[6.6666;6.6666;16.6666;16.6666];
feedSeq=[10;10;13.3333;13.3333];
i=2;
while i<=size(pPathSeq,1)
    if abs(feedSeq(i)-feedSeq(i-1))>0.001 %feed rate changes
        pos_v=[pPathSeq(i-1:i,:),feedSeq(i-1:i)];
        [t_v_pos_d_seq,interpPathSeq,interpFeedSeq,acc,pos_v_d_seq]=interpolateBetweenTwoPos(pos_v,100,true,true,true);
        pPathSeq=[pPathSeq(1:i-1,:);interpPathSeq(2:end-1,:);pPathSeq(i:end,:)];
        feedSeq=[feedSeq(1:i-1);interpFeedSeq(2:end-1);feedSeq(i:end)];
        i=i+size(interpFeedSeq,1)-2;
    end
    i=i+1;
end
% for i=1:size(pPathSeq,1)
%     fprintf('G01 X%.4f Y%.4f Z%.4f F%.4f\n',pPathSeq(i,1),pPathSeq(i,2),pPathSeq(i,3),feedSeq(i)*60);
% end