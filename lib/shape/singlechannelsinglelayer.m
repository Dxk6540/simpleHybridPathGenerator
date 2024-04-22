% date: 20230515
% functions for incline single channel wall
% author: Yuanzhi CHEN

classdef singlechannelsinglelayer
	properties
        shape_="Wall";
    end
    
    methods(Static)
        function [path, pwrSeq,feedSeq,vertices] = genPrintingPath(pwr, fr, traverse, frequency)
            path = [];
            pwrSeq = [];
            feedSeq = [];
            vertices = [];
            zoffset=5.8147;
            lead = 0.01;
            length=30;
            xInterval=5;
            yInterval=8;
            sample=0.005;
            num=length/sample;
            power=singlechannelsinglelayer.getPower(frequency,num)*pwr;
            feedrate=singlechannelsinglelayer.getFeedrate(frequency,num)*fr;
            tempFeedrate=feedrate(4,:)/60;
            tempFeedrate=timeSmooth(tempFeedrate');
            feedrate(4,:)=tempFeedrate*60;
            count=0;
            skip=0;
            for pIndex = 1 : 4
                for fIndex = 1 : 4
                    cPathSeq = zeros(num+4,5);
                    cPwrSeq = zeros(num+4,1);
                    cFeedSeq = zeros(num+4,1);
                    cPathSeq(1,:)=[skip*(length+xInterval)-length-0.5*xInterval-lead-6,(count-3.5)*yInterval,zoffset,0,45];
                    cPwrSeq(1,:)=0;
                    cFeedSeq(1,:)=traverse;
                    cPathSeq(2,:)=[skip*(length+xInterval)-length-0.5*xInterval-lead,(count-3.5)*yInterval,zoffset,0,45];
                    cPwrSeq(2,:)=0;
                    cFeedSeq(2,:)=feedrate(fIndex,1);
                    vertices=[vertices;skip*(length+xInterval)-length-0.5*xInterval,(count-3.5)*yInterval];
                    for point = 1:num
                        cPathSeq(point+2,:)=[skip*(length+xInterval)-length-0.5*xInterval+(point-1)*sample,(count-3.5)*yInterval,zoffset,0,45];
                        if point == 1
                            cPwrSeq(point+2,:)=0;
                        else
                            cPwrSeq(point+2,:)=power(pIndex,point);
                        end
                        cFeedSeq(point+2,:)=feedrate(fIndex,point);
                    end
                    vertices=[vertices;skip*(length+xInterval)-0.5*xInterval,(count-3.5)*yInterval];
                    cPathSeq(num+3,:)=[skip*(length+xInterval)-0.5*xInterval+lead,(count-3.5)*yInterval,zoffset,0,45];
                    cPwrSeq(num+3,:)=0;
                    cFeedSeq(num+3,:)=feedrate(fIndex,point);
                    cPathSeq(num+4,:)=[skip*(length+xInterval)-0.5*xInterval+lead+6,(count-3.5)*yInterval,zoffset,0,45];
                    cPwrSeq(num+4,:)=0;
                    cFeedSeq(num+4,:)=traverse;
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
            temp=path(:,1);
            path(:,1)=path(:,2);
            path(:,2)=temp;
            EDR=(pwrSeq*4)./(feedSeq/60);
            max(EDR)
            min(EDR(EDR~=0))
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
    end
end
