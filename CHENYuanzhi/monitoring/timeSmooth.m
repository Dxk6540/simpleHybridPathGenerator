function data = timeSmooth(data)
%   Detailed explanation goes here
difference=data(2:end,:)-data(1:end-1,:);
stepIndex=find(abs(difference)>1);


for i=1:length(stepIndex)
    if (stepIndex(i)<length(data))
        vs=[data(stepIndex(i)),data(stepIndex(i)+1)];
    else
        break;
    end
    [~,~,feedSeq]=interpolateBetweenTwoPos(vs,false,false);
    %% Find the end of the insert
    if(i<length(stepIndex))
        insert_end=stepIndex(i+1);
    elseif i<length(data)
        insert_end=length(data);
    else break;
    end
    %% Make sure if the interval is large enough to finish the S-shaped smooth
    if(insert_end-stepIndex(i)>length(feedSeq))
        data(stepIndex(i):stepIndex(i)+length(feedSeq)-1)=feedSeq;
    else
        fprintf('Alarm! The interval is too small to finish the smooth.')
    end
end
end