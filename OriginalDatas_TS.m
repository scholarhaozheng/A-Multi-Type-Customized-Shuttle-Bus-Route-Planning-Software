clc;
clear all;
close all;
maxiteration = 200;%---------------ֹͣ����Ϊ����һ������������ֹͣ
vhcnum = 15;%��������
demand = 100;%��������
TravelTimeMax=1000;
markcost = [];
demandstarttime = xlsread('.\passengerdemand_result1.xlsx','F2:G101');
demandendtime = xlsread('.\passengerdemand_result1.xlsx','H2:I101');
demandstartlocation = xlsread('.\passengerdemand_result1.xlsx','B2:C101');
demandendlocation = xlsread('.\passengerdemand_result1.xlsx','D2:E101');
demandlocation=[demandstartlocation;demandendlocation];
demandtime=[demandstarttime;demandendtime];
distancematrix = generatedismatrix1(demandlocation,demandlocation);%----����:����һ��N*2M�ľ���������±�Ϊ����㣬���±�Ϊ���յ�
timematrix = distancematrix*0.2;%�ٶ�30km/h,��λmin
% vhclocation = zeros(vhcnum,1); %����λ��
% vhctype = zeros(vhcnum,1);    %��������
% vhccapacity = zeros(vhcnum,1); %������ؿ���
% vhcdepot = zeros(vhcnum,1);  %����������վ
vhclocation = xlsread('.\vehcleinfomation.xlsx','A2:B16');
vhctype = xlsread('.\vehcleinfomation.xlsx','C2:C16');
vhccapacity = xlsread('.\vehcleinfomation.xlsx','D2:D16');
vhcdepot = xlsread('.\vehcleinfomation.xlsx','O2:O16');
vhcstarttime = xlsread('.\vehcleinfomation.xlsx','F2:G16');
vhcendtime = xlsread('.\vehcleinfomation.xlsx','H2:I16');
fixedcost = xlsread('.\vehcleinfomation.xlsx','J2:J16');%�����̶��ɱ�
% ck = xlsread('C:\Users\lenovo\Desktop\���ƹ�����·�滮����\vehcleinfomation.xlsx','K2:K21');%�������е�λ���ȳɱ�
cwk = xlsread('.\vehcleinfomation.xlsx','L2:L16');%�����ȴ���λʱ��ɱ�
ctk = xlsread('.\vehcleinfomation.xlsx','M2:M16');%�������е�λʱ��ɱ�
% L0 = xlsread('C:\Users\lenovo\Desktop\���ƹ�����·�滮����\vehcleinfomation.xlsx','N2:N21');%�̶��ɱ��������еľ���

%���㳡վ-����timematrix����
% vhcdemanddistancematrix = generatedismatrix1(vhclocation,demandlocation);%----����:����һ��N*2M�ľ���������±�Ϊ����㣬���±�Ϊ���յ�
% vhcdemandtimematrix = vhcdemanddistancematrix*0.2;%�ٶ�30km/h,��λmin
vhcindex = xlsread('.\vehcleinfomation.xlsx','O2:O16');%����-·����� O2:O16Ϊ��������ʼ��վ���
stopshortestdistance = xlsread('.\stop_shortestdistance','A1:CV100');%%�Ʋ�Ϊ����֮����̾���
stopindex1 = xlsread('.\passengerdemand_result1.xlsx','K2:K101');%���������ϳ�վ����
stopindex2 = xlsread('.\passengerdemand_result1.xlsx','L2:L101');%���������³�վ����
demandstopindex = [stopindex1;stopindex2];%����-·�����

vhcdemandtimematrix = calvhcdemandtimematrix(vhcnum,demand,stopshortestdistance,vhcindex,demandstopindex);
[inisolution1,inireject1] = GenerateinisolutionRight0406(demand,demandstarttime,demandendtime,vhclocation,vhcstarttime,vhcendtime,timematrix,vhcdemandtimematrix,vhccapacity,fixedcost,cwk,ctk,TravelTimeMax);%------------��������ʼ�����ɣ���Լ����  
[inicost1,iniobjective1] = calculatetotalcost_test(inisolution1,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk);%-------------------�������Խ���м���Ŀ��ֵ


save OriginalData_TS0407.mat
%%%judgement������һ����