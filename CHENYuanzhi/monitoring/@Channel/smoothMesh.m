function [mesh_smoothedZ] = smoothMesh(obj)
flag_2Dsmoothing=1;% 0 - No smooth, 1 - imgaussfilt smooth, 2 - butterworth smooth, 3 - FFT smooth
%% Smooth the z
mesh_smoothedZ = zeros(size(obj.mesh_z));
if (flag_2Dsmoothing==0)
    obj.mesh_smoothedZ = obj.mesh_z;
elseif (flag_2Dsmoothing==1)
    obj.mesh_smoothedZ = imgaussfilt(obj.mesh_z,2.5);
elseif(flag_2Dsmoothing==2)
    fs=20;%% Determined by the sampling density of the points along the Y direction
    fc=1;
    [b,a] = butter(3,fc/(2*fs));% 3 means 3 degree
    for i = 1:size(mesh_smoothedZ,2)
        mesh_smoothedZ(:,i) = filtfilt(b,a,obj.mesh_z(:,i));
    end
    obj.mesh_smoothedZ=mesh_smoothedZ;
elseif(flag_2Dsmoothing==3)
    F1=obj.mesh_z;

    FFT = fft2(F1);
    myangle = angle(FFT);             %相位谱(没有进行移位的)
    FS = abs(fftshift(FFT));          % 移位，使低频成分集中到图像中心，并得到幅度谱
    S = log(1+abs(FS));
    
    [m,n] = size(FS);
    nNum=round(n*0.05);
    mNum=round(m*0.05);
    FS(1:m/2-mNum,:) = 0;
    FS(m/2+mNum:m,:) = 0;
    FS(m/2-mNum:m/2+mNum,1:n/2-nNum) = 0;
    FS(m/2-mNum:m/2+mNum,n/2+nNum:n) = 0;
    SS = log(1+abs(FS));

    aaa = ifftshift(FS);          % 将处理后的幅度图反移位，恢复到正常状态
    bbb = aaa.*cos(myangle) + aaa.*sin(myangle).*1i;      % 幅度值和相位值重新进行结合，得到复数
    fr = abs(ifft2(bbb));               % 进行傅里叶反变换，得到处理后的时域图像
    obj.mesh_smoothedZ=fr;

    subplot(2,2,1),imshow(F1);
    title('噪声图像');
    subplot(2,2,2),imshow(S,[]);     % 带噪声的幅度图，亮度代表着能量
    title('傅里叶变换后幅度图');
    subplot(2,2,3),imshow(SS,[]);     % 去除外围幅度值后的幅度图，亮度代表着能量
    title('去除外围幅值后幅度图');
%     ret = im2uint8(mat2gray(fr));
    subplot(2,2,4),imshow(fr);       %去除高频成分后的图像
    title('去噪后的图像');
end
end