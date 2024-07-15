% date: 20230515
% functions for incline single channel wall
% author: Yuanzhi CHEN

classdef processTestSinglechannelsinglelayer
	properties
        shape_="Wall";
    end
    
    methods(Static)
        function [path, pwrSeq,feedSeq,vertices] = genPrintingPath(pwr, fr, traverse, lyrNum, lyrHeight)
            path = [];
            pwrSeq = [];
            feedSeq = [];
            vertices = [];
            lead = 0.01;
            length=30;
            xInterval=5;
            yInterval=8;
            sample=1;
            num=length/sample;
            powerStep=12.5;
            feedStep=50;
            power=[ones(1,num)*pwr;ones(1,num)*(pwr+1*powerStep);ones(1,num)*(pwr+2*powerStep);ones(1,num)*(pwr+3*powerStep)];
            feedrate=[ones(1,num)*fr;ones(1,num)*(fr+1*feedStep);ones(1,num)*(fr+2*feedStep);ones(1,num)*(fr+3*feedStep)];
            count=0;
            skip=0;
            for lyrIdx=1:lyrNum
                skip=0;
                for pIndex = 1 : 4
                    for fIndex = 1 : 4
                        zoffset=(lyrIdx-1)*lyrHeight;
                        cPathSeq = zeros(num+8,5);
                        cPwrSeq = zeros(num+8,1);
                        cFeedSeq = zeros(num+8,1);
                        cPathSeq(1,:)=[skip*(length+xInterval)-length-0.5*xInterval-lead-6,(count-3.5)*yInterval,zoffset,0,0];
                        cPwrSeq(1,:)=0;
                        cFeedSeq(1,:)=traverse;
                        cPathSeq(2,:)=[skip*(length+xInterval)-length-0.5*xInterval-lead-3,(count-3.5)*yInterval,zoffset,0,0];
                        cPwrSeq(2,:)=0;
                        cFeedSeq(2,:)=feedrate(fIndex,1);
                        cPathSeq(3,:)=[skip*(length+xInterval)-length-0.5*xInterval-lead-1.5,(count-3.5)*yInterval,zoffset,0,0];
                        cPwrSeq(3,:)=0;
                        cFeedSeq(3,:)=feedrate(fIndex,1);
                        cPathSeq(4,:)=[skip*(length+xInterval)-length-0.5*xInterval-lead,(count-3.5)*yInterval,zoffset,0,0];
                        cPwrSeq(4,:)=0;
                        cFeedSeq(4,:)=feedrate(fIndex,1);
                        vertices=[vertices;(count-3.5)*yInterval,skip*(length+xInterval)-length-0.5*xInterval];
                        for point = 1:num
                            cPathSeq(point+4,:)=[skip*(length+xInterval)-length-0.5*xInterval+(point-1)*sample,(count-3.5)*yInterval,zoffset,0,0];
                            if point == 1
                                cPwrSeq(point+4,:)=0;
                            else
                                cPwrSeq(point+4,:)=power(pIndex,point);
                            end
                            cFeedSeq(point+4,:)=feedrate(fIndex,point);
                        end
                        vertices=[vertices;(count-3.5)*yInterval,skip*(length+xInterval)-0.5*xInterval];
                        cPathSeq(num+5,:)=[skip*(length+xInterval)-0.5*xInterval+lead,(count-3.5)*yInterval,zoffset,0,0];
                        cPwrSeq(num+5,:)=0;
                        cFeedSeq(num+5,:)=feedrate(fIndex,point);
                        cPathSeq(num+6,:)=[skip*(length+xInterval)-0.5*xInterval+lead+1.5,(count-3.5)*yInterval,zoffset,0,0];
                        cPwrSeq(num+6,:)=0;
                        cFeedSeq(num+6,:)=feedrate(fIndex,point);
                        cPathSeq(num+7,:)=[skip*(length+xInterval)-0.5*xInterval+lead+3,(count-3.5)*yInterval,zoffset,0,0];
                        cPwrSeq(num+7,:)=0;
                        cFeedSeq(num+7,:)=feedrate(fIndex,point);
                        cPathSeq(num+8,:)=[skip*(length+xInterval)-0.5*xInterval+lead+6,(count-3.5)*yInterval,zoffset,0,0];
                        cPwrSeq(num+8,:)=0;
                        cFeedSeq(num+8,:)=traverse;
                        path = [path;cPathSeq];
                        pwrSeq = [pwrSeq;cPwrSeq];
                        feedSeq = [feedSeq;cFeedSeq];
                        count=count+1;
                        if count==8 
                            skip=1;
                            count=0;
                        end
                    end
                end
                %power=power-powerStep;
            end
            temp=path(:,1);
            path(:,1)=path(:,2);
            path(:,2)=temp;
            EDR=(pwrSeq*4)./(feedSeq/60);
            max(EDR)
            min(EDR(EDR~=0))
        end
    end
end
