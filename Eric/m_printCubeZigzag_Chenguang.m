%% Eric print cube with Zigzag path

% this is an example of using cPathGen class and cHybridProcess class.
addpath('../lib')

% file param:
pFilename = strcat('./feedTest',date,'.NC');
filename = strcat('./claddingTest',date,'.NC');
lbPt = [];%%% Left bottom point;
genCubeCode(filename, lbPt, 0.5, 500);

function genCubeCode(filename, leftBtmPt, lyrHeight, feed)

hProc = cHybridProcess(filename);

hProc.sPrintParam_.powderMode = 1; % both powder are used
hProc.sProcessParam_.safetyHeight=230;%% Safety height！ Attention

%  geometry param
% startCtr = [0,0]; % left bottom corner

% inclinationAgl = 0; % degree
pLyrNum = 1;%%%% Layer number. 1 layer for 1; 10 mm needs calculation
tol = 0.1;

x_length=20;%%%% Change the side length
y_length=20;%%%% Change the side length
step = 2;%%%% s: the interval between two channels
channel=ceil(y_length/step)+1;
cubeShape = [x_length+4,channel];
handle=zigzagPathCube;
hProc.sPrintParam_.pFeedrate = 500;%%%%%
hProc.sPrintParam_.pwr=200;%%%%%
hProc.sPrintParam_.lenPos=800;
hProc.sPrintParam_.flowL=250;
hProc.sPrintParam_.speedL=50;
hProc.sPrintParam_.flowR=0;
hProc.sPrintParam_.speedR=0;
leftBtmPt=[-40,20];
zOffset = 0;

pg = cPathGen(filename); % create the path generator object
pg.genNewScript();


[pPathSeq,pwrSeq, feedSeq] = handle.genPrintingPathV2(cubeShape, leftBtmPt, tol, pLyrNum, ...
                                                lyrHeight, hProc.sPrintParam_.pwr, zOffset, channel, step);
hProc.genNormalPrintingProcess(pg, pPathSeq, pwrSeq, hProc.sPrintParam_.pFeedrate, hProc.sPrintParam_);    
pg.closeScript();
%% draw the path
pg.drawPath(pPathSeq, pPathSeq);
end