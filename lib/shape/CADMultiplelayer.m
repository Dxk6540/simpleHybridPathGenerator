% date: 20230515
% functions for incline single channel wall
% author: Yuanzhi CHEN

classdef CADMultiplelayer
	properties
        shape_="Wall";
    end
    
    methods(Static)
        function [path, pwrSeq,feedSeq,vertices] = genPrintingPath(pPathSeq, pwr, fr, traverse, pPattern, fPattern, Reverse, B_axis, Z_coord)
            path = [];
            pwrSeq = [];
            feedSeq = [];
            vertices = [];
            zoffset=Z_coord(1);
            lead = 5;
            x=pPathSeq(:,1);
            y=pPathSeq(:,2);
            zeta=rad2deg(atan2(y, x));
            %power & feedrate generation
            num=length(pPathSeq);
            power=doublespiralMultiplelayer.getPower(pPattern,num)*pwr;
            feedrate=doublespiralMultiplelayer.getFeedrate(fPattern,num)*fr;
            if strcmp(fPattern,"square") || strcmp(fPattern,"noise")
                tempFeedrate=feedrate/60;
                tempFeedrate=timeSmooth(tempFeedrate');
                feedrate=(tempFeedrate*60)';
            end
            if Reverse
                x=flipud(x);
                y=flipud(y);
                zeta=flipud(zeta);
            end
            
            path=[path;0,0,zoffset,B_axis,zeta(1)];
            pwrSeq=[pwrSeq,0];
            feedSeq=[feedSeq,traverse];
            path=[path;x(1)-lead,y(1)-lead,zoffset,B_axis,zeta(1)];
            pwrSeq=[pwrSeq,0];
            feedSeq=[feedSeq,feedrate(1)];
            path=[path;x(1)-lead*0.01,y(1)-lead*0.01,zoffset,B_axis,zeta(1)];
            pwrSeq=[pwrSeq,0];
            feedSeq=[feedSeq,feedrate(1)];
            path=[path;x,y,Z_coord',ones(num,1)*B_axis,ones(num,1).*zeta];
            vertices = [vertices;x',y'];
            pwrSeq=[pwrSeq,power];
            feedSeq=[feedSeq,feedrate];
            path=[path;x(end)-lead*0.01,y(end),zoffset,B_axis,zeta(end)];
            pwrSeq=[pwrSeq,0];
            feedSeq=[feedSeq,traverse];
            path=[path;x(end)-lead,y(end),zoffset,B_axis,zeta(end)];
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
            t=t/num.*(2*pi*(1+0.0005*t));
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
            power=power*0.6/2+1;
        end
        
        function feedrate = getFeedrate(fPattern,num)        
            t=1:num;
            t=t/num.*(2*pi*(1+0.0005*t))-0.5*pi;
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
            feedrate=feedrate*0.6/2+1;
        end
    end
end

function filtered_signal = generate_and_filter_signal(sampling_rate, signal_length)
    % 生成初始信号，以3Hz为上限做严格的低通滤波
    
    % 生成白噪声信号
    noise_signal = randn(1, signal_length);
    
    % 计算频率轴
    n = length(noise_signal);
    f = (0:n-1) * sampling_rate / n;
    
    % 应用快速傅里叶变换（FFT）获取频谱
    noise_fft = fft(noise_signal);
    
    % 将3Hz以上的频率成分设为0，以实现严格的低通滤波
    noise_fft(f > 1) = 0;
    
    % 应用逆傅里叶变换（IFFT）获取处理后的信号
    filtered_signal = ifft(noise_fft, 'symmetric');
end