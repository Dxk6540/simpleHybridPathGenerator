% 指定包含txt文件的文件夹路径
folderPath = 'C:\Users\ASUS\Desktop\test1'; % 替换为包含txt文件的文件夹路径

% 获取文件夹中所有txt文件的列表
fileList = dir(fullfile(folderPath, '*.txt'));

% 循环处理每个txt文件
for i = 1:numel(fileList)
    % 读取文件内容
    fileID = fopen(fullfile(folderPath, fileList(i).name), 'r');
    fileData = textread(fullfile(folderPath, fileList(i).name), '%s', 'delimiter', '\n');
    fclose(fileID);

    % 寻找包含 "I0.00" 的行并替换
    for j = 1:numel(fileData)
        if contains(fileData{j}, 'I0.000') || contains(fileData{j}, 'XNan')
            fileData{j} = 'G01 XNan YNan ZNan BNan CNan INan JNan FNan';
        end
    end

    % 将修改后的内容写回文件
    fileID = fopen(fullfile(folderPath, fileList(i).name), 'w');
    fprintf(fileID, '%s\n', fileData{:});
    fclose(fileID);
end