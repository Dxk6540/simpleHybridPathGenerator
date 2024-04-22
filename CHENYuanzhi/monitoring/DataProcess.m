%1. load all melt pool images of one plate
file_path =  'D:\code\simpleHybridPathGenerator\CHENYuanzhi\monitoring\2024_04_19\';
img_path_list = dir(strcat(file_path,'*.bmp'));

%2. load cld data of one plate
filename = strcat(file_path,'SelectedData.txt');
cldData = importdata(filename);

%3. seperate 16 lines
cncTimer=cldData(:,1);
AXIS_X=cldData(:,3);
AXIS_Y=cldData(:,4);
AXIS_Z=cldData(:,5);
data_num=length(cncTimer);
cncLines=zeros(16,2);
Kd_tree = KDTreeSearcher([AXIS_X,AXIS_Y]);
for lineIdx=1:16
    flag=0;
    lines{lineIdx,1}=[];
    startIdx=knnsearch(Kd_tree,vertices(2*lineIdx-1,:));
    startIdx=startIdx+(vertices(2*lineIdx-1,2)>AXIS_Y(startIdx));
    endIdx=knnsearch(Kd_tree,vertices(2*lineIdx,:));
    endIdx=endIdx-(vertices(2*lineIdx-1,2)<AXIS_Y(endIdx));
    cncLines(lineIdx,:)=[startIdx,endIdx];
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
        save parameters.mat samplepoint
        for T=-2*interval:interval:2*interval
            imageName=strcat(file_path,img_path_list(lines{lineIdx,1}(5+step*pointIdx)));
            imageNewName=strcat(dirName,'T',num2str(T));
            copyfile(imageName,imageNewName);
        end
    end
end
