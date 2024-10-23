% 读取图像
imgName='C:\Users\ASUS\Desktop\test1\2.jpg';
img = imread(imgName); % 请将'your_image.jpg'替换为你的图片文件名

% 转换为灰度图像（如果原图是彩色的）
gray_img = rgb2gray(img);

% 使用Canny边缘检测
bw_img = imbinarize(gray_img, 0.8); % 0.5是阈值，你可以根据实际情况调整

% 提取轮廓
[B,L] = bwboundaries(bw_img); % 'noholes'选项表示不填充内部孔洞

% 显示轮廓（假设只有一个物体）
for k = 9:length(B)
    boundary = B{k}; % 获取第k个物体的边界点集
    [x,~] = smooth(boundary(:,2));
    [y,~] = smooth(boundary(:,1));
    [x,~] = smooth(x);
    [y,~] = smooth(y);
    plot(x, y, 'b', 'LineWidth', 2); % 用蓝色绘制边界
    axis equal
    axis off
    print('-dpng', 'boundary2.png', '-r96');
end