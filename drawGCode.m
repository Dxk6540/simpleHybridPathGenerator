fid=fopen(strcat('./fullAutoCylinderTest',date,'.txt'),'r');
path = [];
count=0;
while ~feof(fid)    % while循环表示文件指针没到达末尾，则继续
    % 每次读取一行, str是字符串格式
    count=count+1;
    str = fgetl(fid);     
    
    % 以 ',' 作为分割数据的字符,结果为cell数组
    s=regexp(str,' ','split');    

    %取数组中第一个元素s{1}，先转换成字符串char再转换成数字str2num
    if s{1}=="G01" && s{2}(1)=='X'
        tempx = str2num(char(s{2}(2:end)));  
        tempy = str2num(char(s{3}(2:end))); 
        tempz = str2num(char(s{4}(2:end))); 
        path = [path;tempx,tempy,tempz,count]; 
    end
    if rem(count,100000)==0
        disp(count);
        plot3(path(:,1),path(:,2),path(:,3));
        saveas(gcf, strcat('save',num2str(count),'.jpg'));
        path=[];
    end
end
plot3(path(:,1),path(:,2),path(:,3));
saveas(gcf, strcat('save',num2str(count),'.jpg'));
fclose(fid);