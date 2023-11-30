x1=[125,200,300,400];
y1=1:0.1:1.8;
[X1,Y1]=meshgrid(x1,y1);
surf(X1,Y1,heights1(:,2:end));
hold on
x2=300:100:1200;
y2=0.1:0.1:0.9;
[X2,Y2]=meshgrid(x2,y2);
surf(X2,Y2,cat(2,heights2,heights3));
hold on
x4=1300:100:1700;
y4=0.1:0.1:0.3;
[X4,Y4]=meshgrid(x4,y4);
surf(X4,Y4,heights3(1:3,:));