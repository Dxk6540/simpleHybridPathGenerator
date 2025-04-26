function plotLyrCircles(LyrNum, LyrHeight, R_base, theta, step, LyrShift)
    % 检查输入参数
    if LyrNum <= 0 || LyrHeight <= 0 || R_base <= 0 || step <= 0
        error('所有参数必须为正值。');
    end
    
    % 设置图形
    figure;
    hold on;
    axis equal;    
    grid on;
    path=[];
    LyrShift=LyrShift/step;
    % 计算每层的圆
    for layer = 0:LyrNum-1
        % 当前层的Z坐标
        z = layer * LyrHeight;
        
        % 当前层的半径
        R_current = R_base + layer * (LyrHeight / tan(theta));
        
        % 计算圆的点
        theta_values = 0:step:R_current * 2 * pi; 
        x = R_current * cos(theta_values);
        y = R_current * sin(theta_values);
        lyrPath=[x', y', z * ones(size(x))'];
        if layer>0
            lyrPath=[lyrPath(1+layer*LyrShift:end,:);lyrPath(1:1+layer*LyrShift-1,:)];
        end
        if rem(layer,2)==1
            lyrPath=flipud(lyrPath);
        end
        path=[path;lyrPath];
        % 绘制当前层的圆
        plot3(lyrPath(:,1),lyrPath(:,2),lyrPath(:,3), 'LineWidth', 1.5);
    end
    
    % 设置坐标轴标签
    xlabel('X轴');
    ylabel('Y轴');
    zlabel('Z轴');
    title('多层圆图');
    view(3); % 3D视角
    hold off;
end