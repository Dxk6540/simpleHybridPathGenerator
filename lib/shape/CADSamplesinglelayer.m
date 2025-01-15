% date: 20230515
% functions for incline single channel wall
% author: Yuanzhi CHEN

classdef CADSamplesinglelayer
	properties
        shape_="Wall";
    end
    
    methods(Static)
        function [path, pwrSeq,feedSeq,vertices] = genPrintingPath(pwr, fr, traverse, pPattern, fPattern, Rtcp, dxfFile, skip, Reverse, Frequency)
            %dxfFile='Drawing3.dxf';
            dxf = DXFtool(dxfFile);
            [seq,reverse,group]=connectPoints(dxf.points);
            [Cpath,~,~]=connectPath(dxf,seq,reverse,group);
            Cpath=Cpath(3:end-2,:);
            Cpath=Cpath-mean(Cpath);
            Cpath = insertPointsEvenly(Cpath, 0.011);
            Cpath=Cpath(1:end-skip,:);
            figure
            plot(Cpath(:,1),Cpath(:,2),'*')
            num=length(Cpath);
            path=[];
            pwrSeq = [];
            feedSeq = [];
            vertices = [];
            lead = 5;
            zoffset=0;
            x=Cpath(:,1);
            y=Cpath(:,2);
            zeta=rad2deg(atan2(y, x));
            if Reverse
                x=flipud(x);
                y=flipud(y);
                zeta=flipud(zeta);
            end
            if Rtcp==0
                zeta=zeros(num,1);
            end
            power=CADSamplesinglelayer.getPower(pPattern,num,Frequency)*pwr;
            feedrate=CADSamplesinglelayer.getFeedrate(fPattern,num,Frequency)*fr;
            %power=power./(feedrate/60);
            if strcmp(fPattern,"square") || strcmp(fPattern,"noise")
                tempFeedrate=feedrate/60;
                tempFeedrate=timeSmooth(tempFeedrate');
                feedrate=(tempFeedrate*60)';
            end
            path=[path;0,0,zoffset,0,0];
            pwrSeq=[pwrSeq,0];
            feedSeq=[feedSeq,traverse];
            path=[path;x(1)-lead,y(1)-lead,zoffset,0,zeta(1)];
            pwrSeq=[pwrSeq,0];
            feedSeq=[feedSeq,feedrate(1)];
            path=[path;x(1)-lead*0.01,y(1)-lead*0.01,zoffset,0,zeta(1)];
            pwrSeq=[pwrSeq,0];
            feedSeq=[feedSeq,feedrate(1)];
            path=[path;x,y,ones(num,1)*zoffset,zeros(num,1),ones(num,1).*zeta];
            vertices = [vertices;x(1),y(1);x(end),y(end)];
            pwrSeq=[pwrSeq,power];
            feedSeq=[feedSeq,feedrate];
            path=[path;x(end)-lead*0.01,y(end),zoffset,0,zeta(end)];
            pwrSeq=[pwrSeq,0];
            feedSeq=[feedSeq,traverse];
            path=[path;x(end)-lead,y(end),zoffset,0,zeta(end)];
            pwrSeq=[pwrSeq,0];
            feedSeq=[feedSeq,traverse];
            pwrSeq=pwrSeq';
            feedSeq=feedSeq';
            EDR=(pwrSeq*4)./(feedSeq/60);
            max(EDR)
            min(EDR(EDR~=0))
        end
        
        function power = getPower(pPattern,num,Frequency)           
            t=1:num;
            if strcmp(Frequency,"Low")
                t=t/num.*(2*pi*(1+0.0001*t));
            else
                t=t/num.*(2*pi*(5+0.001*t));
            end
            if strcmp(pPattern, "const")
                power=zeros(1,num);  
            elseif strcmp(pPattern, "tooth")
                power=sawtooth(t,0.5);
            elseif strcmp(pPattern, "sin")
                power=sin(t);
            elseif strcmp(pPattern, "square")
                power=square(t);
                power(end)=power(end-1);
            elseif strcmp(pPattern, "noise")
                power=generate_and_filter_signal(100, num);
                power=power*(1/max(abs(min(power)),max(power)));
            end
            power=power*0.3/2+1;
        end
        
        function feedrate = getFeedrate(fPattern,num,Frequency)        
            t=1:num;
            if strcmp(Frequency,"Low")
                t=t/num.*(2*pi*(1+0.0001*t))-0.5*pi;
            else    
                t=t/num.*(2*pi*(5+0.001*t))-0.5*pi;
            end
            if strcmp(fPattern, "const")
                feedrate=zeros(1,num);  
            elseif strcmp(fPattern, "tooth")
                feedrate=sawtooth(t,0.5);
            elseif strcmp(fPattern, "sin")
                feedrate=sin(t);
            elseif strcmp(fPattern, "square")
                feedrate=square(t);
                feedrate(end)=feedrate(end-1);
            elseif strcmp(fPattern, "noise")
                feedrate=generate_and_filter_signal(100, num);
                feedrate=feedrate*(1/max(abs(min(feedrate)),max(feedrate)));
            end
            feedrate=feedrate*0.3/2+1;
        end
    end
end

function filtered_signal = generate_and_filter_signal(sampling_rate, signal_length)
    % ���ɳ�ʼ�źţ���3HzΪ�������ϸ�ĵ�ͨ�˲�
    
    % ���ɰ������ź�
    noise_signal = randn(1, signal_length);
    
    % ����Ƶ����
    n = length(noise_signal);
    f = (0:n-1) * sampling_rate / n;
    
    % Ӧ�ÿ��ٸ���Ҷ�任��FFT����ȡƵ��
    noise_fft = fft(noise_signal);
    
    % ��3Hz���ϵ�Ƶ�ʳɷ���Ϊ0����ʵ���ϸ�ĵ�ͨ�˲�
    noise_fft(f > 2) = 0;
    
    % Ӧ���渵��Ҷ�任��IFFT����ȡ�������ź�
    filtered_signal = ifft(noise_fft, 'symmetric');
end

function newPoints = insertPointsEvenly(points, threshold)
    n = size(points, 1); % �������
    newPoints=[];
    for i = 1:n-1  % ���������һ����������е�
        point1 = points(i, :);  % ��ǰ��
        point2 = points(i+1, :);  % ��һ����
        newPoints = [newPoints; point1];
        
        distance = norm(point2 - point1);  % ���������ľ���
        if distance > threshold  % ������������ֵ
            % ������Ҫ����ĵ�����ÿ��֮��ľ���
            numPointsToInsert = round(distance / threshold);
            intervalDistance = threshold / numPointsToInsert;
            
            % �ڵ�ǰ�����һ����֮����ȵز����µĵ�
            for j = 1:numPointsToInsert-1
                fraction = j / numPointsToInsert;
                newPoint = point1 + fraction * (point2 - point1);
                newPoints = [newPoints; newPoint];  % ���µ���ӵ�������
            end
        end
    end
end