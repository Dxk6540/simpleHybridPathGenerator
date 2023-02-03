

pg = cPathGen('./test4.txt');
pg.openFile();

pg.closeDoor();

pg.changeMode(1);
pg.setLaser(300, 900, 250, 100, 250, 100);

pg.saftyToPt([nan, nan, 200], [12, 11, 0], 3000);
pg.pauseProgram();
pg.enableLaser(1, 10);

pts = zeros(100,3);
for i = 1:100
    pts(i,:) = [i, i*2,i*3];
end

pg.addPathPts(pts, 600);

pg.disableLaser(1);
pg.openDoor();
pg.endProgram();


pg.closeFile();


