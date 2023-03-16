% file param:
clc
clear
close all

pFilename = strcat('./cylinderTest',date,'.txt');
mFilename = strcat('./cylinderTestMachinig',date,'.txt');

% printing process param
pwr = 300; % 1.2KW / 4kw *1000;
lenPos = 900;
flowL = 250; % 6 L/min / 20L/min * 1000;
speedL = 100;% 2 r/min / 10r/min * 1000;
flowR = 250;% 6 L/min / 20L/min * 1000;
speedR = 100;% 2 r/min / 10r/min * 1000;
pFeedrate = 600; % mm/min
channel = 2;
step = 1;

% machining process param
mFeedrate = 800; % mm/min
spindleSpeed = 10000;
toolNum = 1;
toolRadiu = 4;

%  geometry param
startCtr = [0,0];
% inclinationAgl = 0; % degree
pLyrNum = 30;
lyrHeight = 0.5;
radius = 20;
tol = 0.5;
safetyHeight = 230;
zOffset = 15;

side = -1; % machining inside is -1 and outside is 1
wallOffset = 1.2;

wpHeight = pLyrNum * lyrHeight;
[printPathSeq,pwrSeq] = vase.genPrintingPath(radius, startCtr, tol, pLyrNum, lyrHeight, pwr, zOffset, channel, step);
path = vase.genMachiningPath(radius, startCtr, tol, wpHeight, lyrHeight, toolRadiu, wallOffset, zOffset, side);

