%% Eric print cube with Zigzag path

% this is an example of using cPathGen class and cHybridProcess class.
addpath('../lib')

% file param:
pFilename = strcat('./feedTest',date,'.NC');
filename = strcat('./tensileStrengthEric', string(0.5), '_', string(500),'.NC');
lbPt = [-5,-10];
genCubeCode(filename, lbPt, 0.5, 500);

function genCubeCode(filename, leftBtmPt, lyrHeight, feed)

hProc = cHybridProcess(filename);

hProc.sPrintParam_.powderMode = 1; % both powder are used
hProc.sProcessParam_.safetyHeight=230;%% Safety height！ Attention

%  geometry param
% startCtr = [0,0]; % left bottom corner

% inclinationAgl = 0; % degree
pLyrNum = 20;% One layer for 0.5 mm height
tol = 0.1;
zOffset = 0;
x_length=10;
y_length=10;
step = 0.8;
channel=ceil(y_length/step)+1;
cubeShape = [x_length+1.4,channel];
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