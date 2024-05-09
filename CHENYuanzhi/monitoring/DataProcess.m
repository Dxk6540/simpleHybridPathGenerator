frequency = [1,3,6,9];
high = [0.8,1,1.2];
for i=1:4
    for j=1:3
        process(frequency(i),high(j));
    end
end

function process(frequency,high)
    cd('D:\code\simpleHybridPathGenerator\CHENYuanzhi\monitoring\');
    %1. load all melt pool images of one plate
    file_path =  strcat('D:\code\simpleHybridPathGenerator\CHENYuanzhi\monitoring\SCSL_',num2str(frequency),'_',num2str(high),'\');
    img_path_list = dir(strcat(file_path,'*.bmp'));
    
    %2. load cld data of one plate
    filename = strcat(file_path,'SelectedData.txt');
    cldData = importdata(filename);
    load vertices.mat
    
    %3. seperate 16 lines
    cncTimer=cldData(:,1);
    AXIS_X=cldData(:,3);
    AXIS_Y=cldData(:,4);
    AXIS_Z=cldData(:,5);
    SPEED=cldData(:,9);
    data_num=length(cncTimer);
    cncLines=zeros(16,2);
    cncPoints=[AXIS_X,AXIS_Y];
    searchIdx=1;
    cncTimeIntervals=zeros(16,1);
    error=0;
    for lineIdx=1:16
        Kd_tree = KDTreeSearcher(cncPoints(searchIdx:min(searchIdx+floor(data_num/3),data_num),:));
        [startIdx,D]=knnsearch(Kd_tree,vertices(2*lineIdx-1,:));
        startIdx=searchIdx+startIdx+(vertices(2*lineIdx-1,2)>AXIS_Y(startIdx))-1;
        error=max(error,norm(cncPoints(startIdx,:)-vertices(2*lineIdx-1,:)));
        [endIdx,D]=knnsearch(Kd_tree,vertices(2*lineIdx,:));
        endIdx=searchIdx+endIdx-(vertices(2*lineIdx-1,2)<AXIS_Y(endIdx))-1;
        error=max(error,norm(cncPoints(endIdx,:)-vertices(2*lineIdx,:)));    
        cncLines(lineIdx,:)=[startIdx,endIdx];
        searchIdx=endIdx;
        cncTimeIntervals(lineIdx,1)=cncTimer(endIdx)-cncTimer(startIdx);
    end
    error
    searchIdx=1;
    monitorLines=zeros(16,2);
    monitorTimeIntervals=zeros(16,1);
    monitorTimer=zeros(length(img_path_list),1);
    for imgIdx=1:length(img_path_list)
        clock=str2num(img_path_list(imgIdx).name(1:2));
        minute=clock*60+str2num(img_path_list(imgIdx).name(3:4));
        second=minute*60+str2num(img_path_list(imgIdx).name(5:6));
        millisecond=str2num(img_path_list(imgIdx).name(8:10))/1000;
        monitorTimer(imgIdx,1)=second+millisecond;
    end
    
    for lineIdx=1:16
        flag=0;
        while true
            I=imread(strcat(img_path_list(searchIdx).folder,'\',img_path_list(searchIdx).name));
            if flag==0
                if sum(sum(I>50))<100
                    searchIdx=searchIdx+1;
                    continue;
                else
                    I1=imread(strcat(img_path_list(searchIdx+1).folder,'\',img_path_list(searchIdx+1).name));
                    I2=imread(strcat(img_path_list(searchIdx+2).folder,'\',img_path_list(searchIdx+2).name));
                    if sum(sum(I1>50))<100 || sum(sum(I2>50))<100
                        searchIdx=searchIdx+1;
                        continue;
                    else
                        flag=1;
                        startIdx=searchIdx;
                        tempTimeIntervals=0;
                        while true
                            if cncTimeIntervals(lineIdx,1)-tempTimeIntervals<0.15
                                break;
                            else
                                searchIdx=searchIdx+1;
                                tempTimeIntervals=monitorTimer(searchIdx,1)-monitorTimer(startIdx,1);
                            end
                        end
                    end
                end
            else
                if sum(sum(I>100))>50
                    searchIdx=searchIdx+1;
                    continue;
                else
                    I=imread(strcat(img_path_list(searchIdx+1).folder,'\',img_path_list(searchIdx+1).name));
                    if sum(sum(I>100))>50
                        delete(strcat(img_path_list(searchIdx).folder,'\',img_path_list(searchIdx).name));
                        imwrite(I,strcat(img_path_list(searchIdx).folder,'\',img_path_list(searchIdx).name));
                        searchIdx=searchIdx+1;
                        continue;
                    else
                        flag=0;
                        endIdx=searchIdx-1;
                        monitorLines(lineIdx,:)=[startIdx,endIdx];
                        % img_path_list(startIdx).name
                        % img_path_list(endIdx).name
                        monitorTimeIntervals(lineIdx,1)=monitorTimer(endIdx,1)-monitorTimer(startIdx,1);
                        searchIdx=searchIdx+10;
                        break;
                    end
                end
            end
        end
    end
    
    TimeError=max(abs(monitorTimeIntervals-cncTimeIntervals))
    if max(abs(monitorTimeIntervals-cncTimeIntervals))<0.1
        % for each line, choose 10 points; for each point, save 5(1) iamges, 
        % real power, nominal power, real, feedrate, nominal feedrate
        sampleNum=200;
        samplePoints=zeros(16,sampleNum+1,3);
        cncPoints=[AXIS_X,AXIS_Y,AXIS_Z];
        interval=1;%1,2,4,8
        skip=40+4*interval;
        increment=0;
        for lineIdx=1:16 
            pointNum=monitorLines(lineIdx,2)-monitorLines(lineIdx,1)+1;
            step=floor((pointNum-skip)/sampleNum);
            increment=120*(cncPoints(cncLines(lineIdx,1),2)-vertices(2*lineIdx-1,2))/(SPEED(cncLines(lineIdx,1))+SPEED(cncLines(lineIdx,1)-1));
            ratio=cncTimeIntervals(lineIdx,1)/monitorTimeIntervals(lineIdx,1);
            for samplePointIdx=0:sampleNum
                pointMonitorIdx=skip/2+step*samplePointIdx+monitorLines(lineIdx,1);
                pointTime=cncTimer(cncLines(lineIdx,1))+(monitorTimer(pointMonitorIdx)-monitorTimer(monitorLines(lineIdx,1)))*ratio-increment;
                Kd_tree = KDTreeSearcher(cncTimer);
                [pointCNCIdx,D]=knnsearch(Kd_tree,pointTime,'k',2);
                samplepoint=(cncPoints(pointCNCIdx(1),:)*D(2)+cncPoints(pointCNCIdx(2),:)*D(1))/(D(1)+D(2));
                samplePoints(lineIdx,samplePointIdx+1,:)=samplepoint;
                dirName=strcat('D:\code\simpleHybridPathGenerator\CHENYuanzhi\monitoring\dataProcess\',num2str(frequency),'_',num2str(high),'_',num2str(lineIdx),'_',num2str(samplePointIdx+1),'\');
                mkdir(dirName);
                cd(dirName);
                save parameters.mat samplepoint
                for T=-2:2
                    pointMonitorIdx=skip/2+step*samplePointIdx+T*interval+monitorLines(lineIdx,1);
                    imageName=strcat(file_path,img_path_list(pointMonitorIdx).name);
                    imageNewName=strcat(dirName,'T_',num2str(T),'.bmp');
                    copyfile(imageName,imageNewName);
                end
            end
        end
    else
        disp(file_path);
    end
end