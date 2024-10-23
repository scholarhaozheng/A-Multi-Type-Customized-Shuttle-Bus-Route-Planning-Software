% % R = makerefmat( 1, 89, 2, 2);
% % latlon1=xlsread('.\use.xlsx','B2:C101');
% % latlon2=xlsread('.\use.xlsx','E2:F101');
% % axesm utm   %设置投影方式，这是MATLAT自带的Universal Transverse Mercator （UTM）方式
% % latlon=[latlon1;latlon2];
% % lat=latlon(:,1);
% % lon=latlon(:,2);
% % 
clc;
clear all;
close all;
demand=20;
index=demand+1;
latlon1=xlsread('.\gams0805.xlsx',['B2:C' num2str(index)]);
latlon2=xlsread('.\gams0805.xlsx',['D2:E' num2str(index)]);
tsdepotlatlon=xlsread('.\gams0805.xlsx','B22:C23');
latlon=[latlon1;latlon2;tsdepotlatlon];
lat=latlon(:,1);
lon=latlon(:,2);
R = makerefmat('RasterSize', size(latlon),'Latlim', [39.4333 41.05], 'Lonlim', [115.4167 117.5000]);
[a,b]=latlon2pix(R,lat,lon);
result=[a,b];
xy=[];
for i=1:size(lat,1)
    [UTME,UTMN]=PositionChange(lat(i,1),lon(i,1));
    xy=[xy;UTME,UTMN];
end
part0=[1:demand]';
partadd=[1:size(tsdepotlatlon,1)]';
part0=[part0;partadd];
part1=xy(1:demand,:);
part2=xy(demand+1:2*demand,:);
part3=xy(2*demand+1:end,:);
part3=[part3,zeros(size(tsdepotlatlon,1),2)];
LocationMatrix=[part1,part2];
LocationMatrix=[LocationMatrix;part3];
TimeMatrix=xlsread('.\gams0805.xlsx',['F2:I' num2str(index)]);
if isempty(TimeMatrix)
    TimeMatrix=zeros(demand,4);
end
TimeMatrix=[TimeMatrix;zeros(size(tsdepotlatlon,1),4)];
Mat=[part0,LocationMatrix,TimeMatrix];
Mat=[zeros(1,9);Mat];
xlswrite('resultgams0805.xlsx', Mat, 'sheet1')
%%%csvwrite('result0416.csv',Mat,1,0);

