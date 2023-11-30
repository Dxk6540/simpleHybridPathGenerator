% this is an example of using cPathGen class and cHybridProcess class.
addpath('../lib')

% file param:
pFilename = strcat('./feedTest',date,'.txt');




anchor = [-81.5, -70];
feeds = [50, 125, 200, 300, 400];
heights = 1:0.1:1.8;
j = 9;
for i = 1:5
    filename = strcat('./feedTest', string(heights(j)), '_', string(feeds(i)),'.txt');
    lbPt = anchor + [30*(i-1), 17 * (j-1)];
    genCubeCode(filename, lbPt, heights(j), feeds(i));
end




function genCubeCode(filename, leftBtmPt, lyrHeight, feed)

hProc = cHybridProcess(filename);
hProc.sPrintParam_.pFeedrate = 600; % mm/min
hProc.sPrintParam_.powderMode = 1; % both powder are used


%  geometry param
% startCtr = [0,0]; % left bottom corner

% inclinationAgl = 0; % degree
pLyrNum = 6;
tol = 0.1;
zOffset = -9;
channel = 10;
step = 0.8;
cubeShape = [20, 10];
handle=zigzagPathCube;

pg = cPathGen(filename); % create the path generator object
pg.genNewScript();
hProc.sPrintParam_.pFeedrate = feed;

[pPathSeq,pwrSeq, feedSeq] = handle.genPrintingPathV2(cubeShape, leftBtmPt, tol, pLyrNum, ...
                                                lyrHeight, hProc.sPrintParam_.pwr, zOffset, channel, step);
hProc.genNormalPrintingProcess(pg, pPathSeq, pwrSeq, hProc.sPrintParam_.pFeedrate, hProc.sPrintParam_);    
pg.closeScript();
end



%%% draw the path
% pg.drawPath(pPathSeq, pPathSeq);