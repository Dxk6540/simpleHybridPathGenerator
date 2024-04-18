%1. load all melt pool images of one plate
file_path =  'E:\Code\simpleHybridPathGenerator\CHENYuanzhi\monitoring\meltpool_coaxial\2024_03_27\';% 图像文件夹路径  
img_path_list = dir(strcat(file_path,'*.bmp'));

%2. load cld data of one plate
filename = strcat(file_path,'12');
cldData = importdata(filename);

%3. seperate 16 lines
open_power=cldData.data(:,3);
AXIS_X=cldData.data(:,12);
AXIS_Y=cldData.data(:,13);
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
samplePoints=zeros(16,sampleNum,2);
skip=10;
interval=1;
for lineIdx=1:16
    pointNum=length(lines{lineIdx,1});
    step=floor((pointNum-skip)/sampleNum);
    for pointIdx=1:sampleNum
        point=[AXIS_X(lines{lineIdx,1}(skip/2+step*pointIdx)),AXIS_Y(lines{lineIdx,1}(skip/2+step*pointIdx))];
        [Idx,D]=knnsearch(Kd_tree,point,'k',2);
        samplepoint=(pPathSeq(Idx(1),1:2)*D(1)+pPathSeq(Idx(2),1:2)*D(2))/sum(D);
        samplePoints(lineIdx,pointIdx,:)=samplepoint;
        dirName=strcat('E:\Code\simpleHybridPathGenerator\CHENYuanzhi\monitoring\',num2str(frequency),'_',num2str(high),num2str(lineIdx),'_',num2str(pointIdx),'\');
        mkdir(dirName);
        cd dirName
        save parameters.m samplepoint
        for T=-2*interval:interval:2*interval
            imageName=strcat(file_path,img_path_list(lines{lineIdx,1}(5+step*pointIdx)));
            imageNewName=strcat(dirName,'T',num2str(T));
            copyfile(imageName,imageNewName);
        end
    end
end
