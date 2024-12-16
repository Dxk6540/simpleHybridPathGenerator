imgName='C:\Users\ASUS\Desktop\test1\High_DoubleSpiral_sin_square_Speed.jpg';
img = imread(imgName);
temp=img(:,:,1);
img(:,:,1)=img(:,:,2);
img(:,:,2)=temp;
%imshow(img);
imwrite(img,imgName);