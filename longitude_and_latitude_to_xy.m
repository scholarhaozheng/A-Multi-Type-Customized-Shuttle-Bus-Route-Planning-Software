clc;
close all;
clear all;

latlon1=xlsread('.\use.xlsx','B2:C101');
latlon2=xlsread('.\use.xlsx','E2:F101');
axesm utm   %����ͶӰ��ʽ������MATLAT�Դ���Universal Transverse Mercator ��UTM����ʽ
latlon20=[latlon1;latlon2];
Z=utmzone(latlon20); %utmzone����latlon20���������ѡ������Ϊ���ʵ�ͶӰ���򣬿�����һ��̨վ�ľ�γ�ȣ�Ҳ����������̨վ�ľ�γ�ȣ���ʱ��ƽ����

setm(gca,'zone',Z)

h = getm(gca)

R=zeros(size(latlon20));

for i=1:length(latlon20)
    
    [x,y]= mfwdtran(h,latlon20(i,1),latlon20(i,2)); %����MATLAB�Դ��ĺ�����������ǰ���õ�Z�����̨վ����ת������
    
    R(i,:)=[x;y];
    
end

dlmwrite('coordinate.txt',R)

figure; plot(R(:,1),R(:,2),'ro','linewidth',6) %��ֱ�������»�����Щ̨վ
