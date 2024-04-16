%1. load all melt pool images of one plate
file_path =  'E:\Code\simpleHybridPathGenerator\CHENYuanzhi\monitoring\meltpool_coaxial\2024_03_27\';% 图像文件夹路径  
img_path_list = dir(strcat(file_path,'*.bmp'));

%2. load cld data of one plate


%3. seperate 16 lines
open_power=pwrSeq;
data_num=length(open_power);
lines=cell(16,1);
startIdx=1;
for lineIdx=1:16
    flag=0;
    lines{lineIdx,1}=[];
    for i=startIdx:data_num
        if open_power(i)<100 && flag==1
            startIdx=i;
            break;
        elseif open_power(i)>100
            lines{lineIdx,1}=[lines{lineIdx,1},i];
            flag=1;
        end
    end
end

% for each line, choose 10 points; for each point, save 5(1) iamges, 
% real power, nominal power, real, feedrate, nominal feedrate
sampleNum=10;
Kd_tree = KDTreeSearcher(pPathSeq(:,1:2));
for lineIdx=1:16
    pointNum=length(lines{lineIdx,1});
    step=floor((pointNum-10)/sampleNum);
    knnsearch(Kd_tree,point,'K',1);
end
