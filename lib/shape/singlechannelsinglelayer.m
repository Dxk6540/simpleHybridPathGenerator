+% date: 20230515
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
                    cPathSeq = zeros(num+8,5);
                    cPwrSeq = zeros(num+8,1);
                    cFeedSeq = zeros(num+8,1);
                    cPathSeq(1,:)=[skip*(length+xInterval)-length-0.5*xInterval-lead-6,(count-3.5)*yInterval,zoffset,0,45];
                    cPwrSeq(1,:)=0;
                    cFeedSeq(1,:)=traverse;
                    cPathSeq(2,:)=[skip*(length+xInterval)-length-0.5*xInterval-lead-3,(count-3.5)*yInterval,zoffset,0,45];
                    cPwrSeq(2,:)=0;
                    cFeedSeq(2,:)=feedrate(fIndex,1);
                    cPathSeq(3,:)=[skip*(length+xInterval)-length-0.5*xInterval-lead-1.5,(count-3.5)*yInterval,zoffset,0,45];
                    cPwrSeq(3,:)=0;
                    cFeedSeq(3,:)=feedrate(fIndex,1);
                    cPathSeq(4,:)=[skip*(length+xInterval)-length-0.5*xInterval-lead,(count-3.5)*yInterval,zoffset,0,45];
                    cPwrSeq(4,:)=0;
                    cFeedSeq(4,:)=feedrate(fIndex,1);
                    vertices=[vertices;(count-3.5)*yInterval,skip*(length+xInterval)-length-0.5*xInterval];
                    for point = 1:num
                        cPathSeq(point+4,:)=[skip*(length+xInterval)-length-0.5*xInterval+(point-1)*sample,(count-3.5)*yInterval,zoffset,0,45];
                        if point == 1
                            cPwrSeq(point+4,:)=0;
                        else
                            cPwrSeq(point+4,:)=power(pIndex,point);
                        end
                        cFeedSeq(point+4,:)=feedrate(fIndex,point);
                    end
                    vertices=[vertices;(count-3.5)*yInterval,skip*(length+xInterval)-0.5*xInterval];
                    cPathSeq(num+5,:)=[skip*(length+xInterval)-0.5*xInterval+lead,(count-3.5)*yInterval,zoffset,0,45];
                    cPwrSeq(num+5,:)=0;
                    cFeedSeq(num+5,:)=feedrate(fIndex,point);
                    cPathSeq(num+6,:)=[skip*(length+xInterval)-0.5*xInterval+lead+1.5,(count-3.5)*yInterval,zoffset,0,45];
                    cPwrSeq(num+6,:)=0;
                    cFeedSeq(num+6,:)=feedrate(fIndex,point);
                    cPathSeq(num+7,:)=[skip*(length+xInterval)-0.5*xInterval+lead+3,(count-3.5)*yInterval,zoffset,0,45];
                    cPwrSeq(num+7,:)=0;
                    cFeedSeq(num+7,:)=feedrate(fIndex,point);
                    cPathSeq(num+8,:)=[skip*(length+xInterval)-0.5*xInterval+lead+6,(count-3.5)*yInterval,zoffset,0,45];
                    cPwrSeq(num+8,:)=0;
                    cFeedSeq(num+8,:)=traverse;
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
