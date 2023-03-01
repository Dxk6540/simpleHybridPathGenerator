fid=fopen(strcat('./fullAutoCylinderTest',date,'.txt'),'r');
path = [];
count=0;
while ~feof(fid)    % whileѭ����ʾ�ļ�ָ��û����ĩβ�������
    % ÿ�ζ�ȡһ��, str���ַ�����ʽ
    count=count+1;
    str = fgetl(fid);     
    
    % �� ',' ��Ϊ�ָ����ݵ��ַ�,���Ϊcell����
    s=regexp(str,' ','split');    

    %ȡ�����е�һ��Ԫ��s{1}����ת�����ַ���char��ת��������str2num
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