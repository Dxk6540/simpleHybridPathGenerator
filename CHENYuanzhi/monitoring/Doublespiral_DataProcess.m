interval = [1,2,4,8,16,24,32,40,48,56,64];
sample = [100,200,400,600];
num=30/0.005;
for l=1:length(interval)
    for m=1:length(sample)
%         for i=1:4
%             for j=1:3
%                 pwr = 800*high(j); % 1.2KW / 4kw *1000;
%                 fr = 400*high(j); % mm/min
%                 power=getPower(frequency(i),num)*pwr;
%                 feedrate=getFeedrate(frequency(i),num)*fr;
%                 tempFeedrate=feedrate(4,:)/60;
%                 tempFeedrate=timeSmooth(tempFeedrate');
%                 feedrate(4,:)=tempFeedrate*60;
%                 process(frequency(i),high(j),interval(l),sample(m),power,feedrate,num);
%                 cd("F:\LSTM_data\matlab");
%             end
%         end
        cd("F:\LSTM_data\matlab");
        geometryExtractionByPt(interval(l),sample(m));
    end
end

function power = getPower(frequency, num)
    power=zeros(4,num);
    power(1,:)=0;
    t=1:num;
    t=t/num*(2*pi*frequency);
    power(2,:)=sawtooth(t,0.5);
    power(3,:)=sin(t);
    power(4,:)=square(t);
    power(4,end)=power(4,end-1);
    power=power*0.3/2+1;
end

function feedrate = getFeedrate(frequency,num)
    feedrate=zeros(4,num);
    feedrate(1,:)=0;
    t=1:num;
    t=t/num*(2*pi*frequency)-0.5*pi;
    feedrate(2,:)=sawtooth(t,0.5);
    feedrate(3,:)=sin(t);
    feedrate(4,:)=square(t);
    feedrate(4,end)=feedrate(4,end-1);            
    feedrate=feedrate*0.4/2+1;
end

function process(frequency,high,interval,sampleNum,power,feedrate,num)
    cd('F:\LSTM_data\matlab\');
    %1. load all melt pool images of one plate
    file_path =  strcat('F:\LSTM_data\matlab\SCSL_',num2str(frequency),'_',num2str(high),'\');
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
    Kd_tree = KDTreeSearcher(cncTimer);
    if max(abs(monitorTimeIntervals-cncTimeIntervals))<0.1
        % for each line, choose 10 points; for each point, save 5(1) iamges, 
        % real power, nominal power, real, feedrate, nominal feedrate
        cncPoints=[AXIS_X,AXIS_Y,AXIS_Z];
        skip=40+4*interval;
        increment=0;
        mkdir(strcat('E:\Code\LSTM\cnn-lstm\datasets\interval_',num2str(interval),'_',num2str(sampleNum),'\'));
        for lineIdx=1:16 
            pIndex=floor(lineIdx/4)+1;
            fIndex=rem(lineIdx,4);
            if fIndex==0
                fIndex=4;
                pIndex=pIndex-1;
            end
            pointNum=monitorLines(lineIdx,2)-monitorLines(lineIdx,1)+1;
            sampleNumReal=min(pointNum-skip,sampleNum);
            vector = (1:pointNum-skip)';
            shuffled_vector = vector(randperm(length(vector)));
            random_elements = shuffled_vector(1:sampleNumReal);
            increment=120*(cncPoints(cncLines(lineIdx,1),2)-vertices(2*lineIdx-1,2))/(SPEED(cncLines(lineIdx,1))+SPEED(cncLines(lineIdx,1)-1));
            ratio=cncTimeIntervals(lineIdx,1)/monitorTimeIntervals(lineIdx,1);
            for samplePointIdx=1:sampleNumReal
                pointMonitorIdx=skip/2+random_elements(samplePointIdx)+monitorLines(lineIdx,1);
                pointTime=cncTimer(cncLines(lineIdx,1))+(monitorTimer(pointMonitorIdx)-monitorTimer(monitorLines(lineIdx,1)))*ratio-increment;
                samplepoint = getSamplePoint(Kd_tree,pointTime,cncPoints);
                dirName=strcat('E:\Code\LSTM\cnn-lstm\datasets\interval_',num2str(interval),'_',num2str(sampleNum),'\',num2str(frequency),'_',num2str(high),'_',num2str(lineIdx),'_',num2str(samplePointIdx),'\');
                mkdir(dirName);
                cd(dirName);
                fileID = fopen('parameters.txt', 'w');
                save parameters.mat samplepoint
                for T=-2:2
                    pointMonitorIdx=skip/2+random_elements(samplePointIdx)+T*interval+monitorLines(lineIdx,1);
                    pointTime=cncTimer(cncLines(lineIdx,1))+(monitorTimer(pointMonitorIdx)-monitorTimer(monitorLines(lineIdx,1)))*ratio-increment;
                    samplepoint = getSamplePoint(Kd_tree,pointTime,cncPoints);
                    if samplepoint(2)>0
                        samplepoint(2)=samplepoint(2)-35;
                    end
                    samplePwr=power(pIndex,floor((samplepoint(2)+32.5)/30*num));
                    sampleFr=feedrate(fIndex,floor((samplepoint(2)+32.5)/30*num));
                    deltaPwr=(power(pIndex,floor(1+(samplepoint(2)+32.5)/30*num))-samplePwr)/0.005;
                    deltaFr=(feedrate(fIndex,floor(1+(samplepoint(2)+32.5)/30*num))-sampleFr)/0.005;
                    text=strcat(num2str(samplePwr),',',num2str(sampleFr),',',num2str(deltaPwr),',',num2str(deltaFr));
                    fprintf(fileID, '%s\n', text);
                    imageName=strcat(file_path,img_path_list(pointMonitorIdx).name);
                    [path, base_name,~]=fileparts(imageName);
                    imageName = fullfile(path, [base_name, '.fea']);
                    imageNewName=strcat(dirName,'T_',num2str(T),'.fea');
                    copyfile(imageName,imageNewName);
                end
                fclose(fileID);
            end
        end
    else
        disp(file_path);
    end
end

function samplepoint = getSamplePoint(Kd_tree,pointTime,cncPoints)
    [pointCNCIdx,D]=knnsearch(Kd_tree,pointTime,'k',2);
    samplepoint=(cncPoints(pointCNCIdx(1),:)*D(2)+cncPoints(pointCNCIdx(2),:)*D(1))/(D(1)+D(2));
end