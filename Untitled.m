addpath('./lib')
bt = bendTube()
p.pwr = 600;
% path,axisSeq,pwrSeq = bt.genPrintingPath(bt.getDefaultParam(),p);
geoParam = bt.getDefaultParam();
geoParam.center = [20,20,0];
geoParam.bendDir = [1,1,0];
[a,b,c] = bt.genPrintingPath(geoParam,p);

pg = cPathGen('test.txt');
pg.draw_ = true;
pg.drawPath(a, b);
