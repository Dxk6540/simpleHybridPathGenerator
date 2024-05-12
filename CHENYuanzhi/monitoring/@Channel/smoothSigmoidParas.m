function smoothedSigmoidParas=smoothSigmoidParas(obj,sigmoidParas,windowNum)
%% Moving average smoothing curve
if windowNum==-1
    windowNum=floor(size(obj.sigmoidParas,1)*0.2);
end
fk = 20;%% Determined by the sampling density of the points along the Y direction,2*density
fs = 1;  % 截止频率（以Hz为单位）
butter_degree=3;
[b, a] = butter(butter_degree, fs/(0.5*fk));
smoothedSigmoidParas=obj.sigmoidParas;
for i=1:(size(obj.sigmoidParas,2)-1)
    smoothedSigmoidParas(:,i)=filtfilt(b, a, sigmoidParas(:,i));
    %     smoothedSigmoidParas(:,i)=movmedian(sigmoidParas(:,i),windowNum);
    %     smoothedSigmoidParas(:,i)=filloutliers(obj.sigmoidParas(:,i),'linear','movmedian',windowNum);
    %     smoothedSigmoidParas(:,i)=smoothdata(obj.sigmoidParas(:,i),'rloess') ;
end
obj.smoothedSigmoidParas=smoothedSigmoidParas;
end