clc;
close all;
clear all;

latlon1=xlsread('.\use.xlsx','B2:C101');
latlon2=xlsread('.\use.xlsx','E2:F101');
axesm utm   %设置投影方式，这是MATLAT自带的Universal Transverse Mercator （UTM）方式
latlon20=[latlon1;latlon2];
Z=utmzone(latlon20); %utmzone根据latlon20里面的数据选择他认为合适的投影区域，可以是一个台站的经纬度，也可以是所有台站的经纬度（此时是平均）

setm(gca,'zone',Z)

h = getm(gca)

R=zeros(size(latlon20));

for i=1:length(latlon20)
    
    [x,y]= mfwdtran(h,latlon20(i,1),latlon20(i,2)); %调用MATLAB自带的函数，根据先前设置的Z，逐个台站进行转换计算
    
    R(i,:)=[x;y];
    
end

dlmwrite('coordinate.txt',R)

figure; plot(R(:,1),R(:,2),'ro','linewidth',6) %在直角坐标下画出这些台站
