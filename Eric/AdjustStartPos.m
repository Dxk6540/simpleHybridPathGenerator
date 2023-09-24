function [new_pPathSeq,new_pwrSeq,new_feedrateOffset]=AdjustStartPos(pPathSeq,pwrSeq,feedrateOffset)
%% Modify the start melting point of differenty layers
z_heights=unique(pPathSeq(:,3));
E_segment_index=[];
for i=1:length(z_heights) % Calculate the segment index
    E_temporary_index=find(pPathSeq(:,3)==z_heights(i));
    E_segment_index=[E_segment_index;E_temporary_index(end)];
end
layer_point_num=E_segment_index(1);
segment_num=16;
single_adjust=floor(layer_point_num/segment_num);
new_pPathSeq=[];
new_pwrSeq=[];
new_feedrateOffset=[];
for i=1:length(z_heights)
    if i<segment_num+1
        coeff=rem(i,segment_num+1)-1;
    else
        coeff=rem(i,segment_num);
    end
    temp_array=pPathSeq((i-1)*layer_point_num+1:(i-1)*layer_point_num+coeff*single_adjust,:);
    temp_array=[pPathSeq((i-1)*layer_point_num+coeff*single_adjust+1:i*layer_point_num,:);temp_array];
    new_pPathSeq=[new_pPathSeq;temp_array];
    temp_array=pwrSeq((i-1)*layer_point_num+1:(i-1)*layer_point_num+coeff*single_adjust,:);
    temp_array=[pwrSeq((i-1)*layer_point_num+coeff*single_adjust+1:i*layer_point_num,:);temp_array];
    new_pwrSeq=[new_pwrSeq;temp_array];
    temp_array=feedrateOffset((i-1)*layer_point_num+1:(i-1)*layer_point_num+coeff*single_adjust,:);
    temp_array=[feedrateOffset((i-1)*layer_point_num+coeff*single_adjust+1:i*layer_point_num,:);temp_array];
    new_feedrateOffset=[new_feedrateOffset;temp_array];
end
end