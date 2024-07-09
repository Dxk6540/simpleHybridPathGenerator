% date: 20230515
% functions for incline single channel wall
% author: Yuanzhi CHEN

classdef doublespiralsinglelayer
	properties
        shape_="Wall";
    end
    
    methods(Static)
        function [path, pwrSeq,feedSeq,vertices] = genPrintingPath(pwr, fr, traverse, pPattern, fPattern, Rtcp)
            path = [];
            pwrSeq = [];
            feedSeq = [];
            vertices = [];
            zoffset=0;
            lead = 5;
            
            %spiral generation
            Length=400;
            sample=0.1;
            n=[0:sample:Length];
            w=2*pi;
            b=1.7;            
            a1=1;
            t1=(sqrt((w*a1)^2+2*b*w^2.*n)-a1*w)/(b*w^2);
            zeta1=w*t1;
            r1=a1+b*zeta1;
            x1=r1.*cos(zeta1);
            y1=r1.*sin(zeta1);
            a2=a1+b*pi;
            t2=(sqrt((w*a2)^2+2*b*w^2.*n)-a2*w)/(b*w^2);
            zeta2=w*t2;
            r2=a2+b*zeta2;
            x2=r2.*cos(zeta2);
            y2=r2.*sin(zeta2);
            x2=fliplr(x2);
            y2=fliplr(y2);            
%             plot(x1, y1); % 绘制螺旋�?
%             axis equal; % 保持坐标轴比例一�?
%             hold on
%             plot(x2,y2);

            %power & feedrate generation
            num=Length/sample+1;
            power=doublespiralsinglelayer.getPower(pPattern,num)*pwr;
            feedrate=doublespiralsinglelayer.getFeedrate(fPattern,num)*fr;
            if strcmp(fPattern,"square") || strcmp(fPattern,"noise")
                tempFeedrate=feedrate/60;
                tempFeedrate=timeSmooth(tempFeedrate');
                feedrate=(tempFeedrate*60)';
            end
            zeta1=zeta1';
            zeta2=zeta2';
            if Rtcp(1)==0
                zeta1=zeros(num,1);
            end
            if Rtcp(2)==0
                zeta2=zeros(num,1);
            end
            path=[path;0,0,zoffset,0,0];
            pwrSeq=[pwrSeq,0];
            feedSeq=[feedSeq,traverse];
            path=[path;x1(1)-lead,y1(1)-lead,zoffset,0,zeta1(1)/(2*pi)*360];
            pwrSeq=[pwrSeq,0];
            feedSeq=[feedSeq,feedrate(1)];
            path=[path;x1(1)-lead*0.01,y1(1)-lead*0.01,zoffset,0,zeta1(1)/(2*pi)*360];
            pwrSeq=[pwrSeq,0];
            feedSeq=[feedSeq,feedrate(1)];
            path=[path;x1',y1',ones(num,1)*zoffset,zeros(num,1),ones(num,1).*zeta1/(2*pi)*360];
            vertices = [vertices;x1',y1',ones(num,1)*zoffset,zeros(num,1),ones(num,1).*zeta1/(2*pi)*360];
            pwrSeq=[pwrSeq,power];
            feedSeq=[feedSeq,feedrate];
            path=[path;x1(end)-lead*0.01,y1(end),zoffset,0,zeta1(end)/(2*pi)*360];
            pwrSeq=[pwrSeq,0];
            feedSeq=[feedSeq,traverse];
            path=[path;x1(end)-lead,y1(end),zoffset,0,zeta1(end)/(2*pi)*360];
            pwrSeq=[pwrSeq,0];
            feedSeq=[feedSeq,traverse];
            path=[path;x2(1)+lead,y2(1)+lead,zoffset,0,zeta2(1)/(2*pi)*360];
            pwrSeq=[pwrSeq,0];
            feedSeq=[feedSeq,traverse];
            path=[path;x2(1)+lead,y2(1)+lead,zoffset,0,zeta2(1)/(2*pi)*360];
            pwrSeq=[pwrSeq,0];
            feedSeq=[feedSeq,feedrate(1)];
            path=[path;x2(1)+lead*0.01,y2(1)+lead*0.01,zoffset,0,zeta2(1)/(2*pi)*360];
            pwrSeq=[pwrSeq,0];
            feedSeq=[feedSeq,feedrate(1)];
            path=[path;x2',y2',ones(num,1)*zoffset,zeros(num,1),ones(num,1).*zeta2/(2*pi)*360];
            vertices = [vertices;x2',y2',ones(num,1)*zoffset,zeros(num,1),ones(num,1).*zeta2/(2*pi)*360];
            pwrSeq=[pwrSeq,power];
            feedSeq=[feedSeq,feedrate]; 
            path=[path;x2(end),y2(end)-lead*0.01,zoffset,0,zeta2(end)/(2*pi)*360];
            pwrSeq=[pwrSeq,0];
            feedSeq=[feedSeq,traverse];
            path=[path;x2(end),y2(end)-lead,zoffset,0,zeta2(end)/(2*pi)*360];
            pwrSeq=[pwrSeq,0];
            feedSeq=[feedSeq,traverse];
            pwrSeq=pwrSeq';
            feedSeq=feedSeq';
            EDR=(pwrSeq*4)./(feedSeq/60);
            max(EDR)
            min(EDR(EDR~=0))
        end
        
        function power = getPower(pPattern, num)           
            t=1:num;
            t=t/num.*(2*pi*(5+0.01*t));
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
        
        function feedrate = getFeedrate(fPattern,num)        
            t=1:num;
            t=t/num.*(2*pi*(5+0.01*t))-0.5*pi;
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