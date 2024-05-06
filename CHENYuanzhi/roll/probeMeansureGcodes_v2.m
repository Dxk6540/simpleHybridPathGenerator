function probeMeansureGcodes_v2(data,RTCP,name)
%% data is a N*7 matrix, column 1~5 is X,Y,Z,B,C.
% if column 6 is 0, it is a transition point; if it is 1, it is a measurement point
% Column 7 means the seeking vector, and the unit is mm.
% RTCP is a bool value.
% name is the file name.
%% Attention! radius = 2 mm.
fid=fopen(name,'wt');
%% probe initialization'
fprintf(fid,';;;;----------------probe initialization----------------;;;;\n');
initialProbe=['#1001=0 ;;single detect\n' ...
    '#1002=1 ;;tip shape: 1 is sphere\n' ...
    '#1003=0 ;;tip radius\n' ...
    '#1004=0 ;;measure delay compensation\n' ...
    '#1027=0.8 ;;retract distance\n' ...
    '#1028=200 ;;initial speed\n' ...
    '#1029=100 ;;second speed\n' ...
    '#40=1.0000 ;;seek distance\n' ...
    'G54 ;;SM coordinate system\n' ...
    'M93 ;;Z1 axis\n' ...
    'T15M6 ;;change to #15 tool: probe\n' ...
    'M13 ;;open the probe\n' ...
    'M23 ;;open the contact protection\n' ...
    'M19P0 ;;rotate the spindle to the initial position\n'];
fprintf(fid,initialProbe);
if(RTCP)
    fprintf(fid,'G43.4H15 ;;tool length compensation\n');
else
    fprintf(fid,'G43H15 ;;tool length compensation\n');
end
%% detect
fprintf(fid,';;;;----------------detect----------------;;;;\n');
detectNum=0;
for i=1:size(data,1)
    pts=data(i,:);
    fprintf(fid,'G01 X%.4f Y%.4f Z%.4f B%.4f C%.4f F2000\n', pts(1),pts(2),pts(3),pts(4),pts(5));
    if pts(6)>0
        detectNum=detectNum+1;
        fprintf(fid,';;%d point\n', detectNum);
        switch pts(6)
            case 1
                fprintf(fid,'G65 [PROBE/O9101] X[%.4f] Y[%.4f] Z[%.4f]\n',pts(7),pts(8),pts(9));
            case 2
                fprintf(fid,'G65 [PROBE/O9101] Y[%.4f] Y[%.4f] Z[%.4f]\n',pts(7),pts(8),pts(9));
            case 3
                fprintf(fid,'G65 [PROBE/O9101] Z[%.4f] Y[%.4f] Z[%.4f]\n',pts(7),pts(8),pts(9));
        end
        fprintf(fid,'#%d=#301\n', 500+detectNum*3-2);
        fprintf(fid,'#%d=#302\n', 500+detectNum*3-1);
        fprintf(fid,'#%d=#303\n', 500+detectNum*3);
    end
end
%% close
fprintf(fid,';;;;----------------finish detection----------------;;;;\n');
endCommands=['M24 ;;close the protection\n' ...
    'M14 ;;close the probe\n' ...
    'M30\n'];
fprintf(fid,endCommands);
fclose(fid);
end