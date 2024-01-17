% this is an example of using cPathGen class and cHybridProcess class.
addpath('../lib')

% file param:
pFilename = strcat('./feedTest',date,'.txt');

filename = strcat('./feedTestEric', string(0.5), '_', string(500),'.txt');
lbPt = [-10,-40];
genCubeCode(filename, lbPt, 0.5, 500);

function genCubeCode(filename, leftBtmPt, lyrHeight, feed)

hProc = cHybridProcess(filename);

hProc.sPrintParam_.powderMode = 1; % both powder are used


%  geometry param
% startCtr = [0,0]; % left bottom corner

% inclinationAgl = 0; % degree
pLyrNum = 20;
tol = 0.1;
zOffset = 10;
channel = 20;
step = 0.8;
cubeShape = [20,channel];
handle=zigzagPathCube;

pg = cPathGen(filename); % create the path generator object
pg.genNewScript();
hProc.sPrintParam_.pFeedrate = feed;

[pPathSeq,pwrSeq, feedSeq] = handle.genPrintingPathV2(cubeShape, leftBtmPt, tol, pLyrNum, ...
                                                lyrHeight, hProc.sPrintParam_.pwr, zOffset, channel, step);
hProc.genNormalPrintingProcess(pg, pPathSeq, pwrSeq, hProc.sPrintParam_.pFeedrate, hProc.sPrintParam_);    
pg.closeScript();
%% draw the path
pg.drawPath(pPathSeq, pPathSeq);
end



