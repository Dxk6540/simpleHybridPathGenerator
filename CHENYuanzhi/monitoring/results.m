interval=[1,2,4,8,16];
smaple=[11,41,201,401];
LSTMResult=zeros(length(sample),length(interval),4);
CNNResult=zeros(length(sample),length(interval),4);
for i=1:length(interval)
    for j=1:length(sample)
        path=strcat('E:\Code\LSTM\cnn-lstm\snapshots\cnn\interval_',num2str(interval(i)),'_',num2str(smaple(j)),'\');
        if exist(path,'dir')
            cd(path)
            load('mse.txt')
            CNNResult(j,i,:)=min(mse,[],1);
        end
        path=strcat('E:\Code\LSTM\cnn-lstm\snapshots\cnnlstm\interval_',num2str(interval(i)),'_',num2str(smaple(j)),'\');
        if exist(path,'dir')
            cd(path)
            load('mse.txt')
            LSTMResult(j,i,:)=min(mse,[],1);
        end
    end
end