% date: 20230515
% functions for incline single channel wall
% author: Yuanzhi CHEN

classdef singlechannelsinglelayer
	properties
        shape_="Wall";
    end
    
    methods(Static)
        function [path, pwrSeq,feedSeq] = genPrintingPath(pwr, fr, traverse, frequency)
            path = [];
            pwrSeq = [];
            feedSeq = [];
            lead = 1;
            length=36;
            xInterval=5;
            yInterval=8;
            sample=0.005;
            num=length/sample;
            power=singlechannelsinglelayer.getPower(frequency,num)*pwr;
            feedrate=singlechannelsinglelayer.getFeedrate(frequency,num)*fr;
            count=0;
            skip=0;
            for pIndex = 1 : 4
                for fIndex = 1 : 4
                    cPathSeq = zeros(num+2,5);
                    cPwrSeq = zeros(num+2,1);
                    cFeedSeq = zeros(num+2,1);
                    cPathSeq(1,:)=[skip*(length+xInterval)-length-0.5*xInterval-lead,(count-3.5)*yInterval,0,0,0];
                    cPwrSeq(1,:)=0;
                    cFeedSeq(1,:)=traverse;
                    for point = 1:num
                        cPathSeq(point+1,:)=[skip*(length+xInterval)-length-0.5*xInterval+(point-1)*sample,(count-3.5)*yInterval,0,0,0];
                        cPwrSeq(point+1,:)=power(pIndex,point);
                        cFeedSeq(point+1,:)=feedrate(fIndex,point);
                    end
                    cPathSeq(num+2,:)=[skip*(length+xInterval)-0.5*xInterval+lead,(count-3.5)*yInterval,0,0,0];
                    cPwrSeq(num+2,:)=0;
                    cFeedSeq(num+2,:)=traverse;
                    count=count+1;
                    if count==8
                        skip=1;
                        count=0;
                    end
                    path = [path;cPathSeq];
                    pwrSeq = [pwrSeq;cPwrSeq];
                    feedSeq = [feedSeq;cFeedSeq];
                end
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
            power=power*0.4/2+1;
        end
        
        function feedrate = getFeedrate(frequency,num)
            feedrate=zeros(4,num);
            feedrate(1,:)=0;
            t=1:num;
            t=t/num*(2*pi*frequency);
            feedrate(2,:)=sawtooth(t,0.5);
            feedrate(3,:)=sin(t);
            feedrate(4,:)=square(t);
            feedrate(4,end)=feedrate(4,end-1);
            feedrate=-feedrate*0.4/2+1;
        end
    end
end
