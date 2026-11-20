clc;
clear all;
close all;
maxiteration = 200;%---------------停止规则为到达一定迭代步数即停止
vhcnum = 15;%车辆数量
demand = 100;%需求数量
TravelTimeMax=1000;
markcost = [];
demandstarttime = xlsread('.\passengerdemand_result1.xlsx','F2:G101');
demandendtime = xlsread('.\passengerdemand_result1.xlsx','H2:I101');
demandstartlocation = xlsread('.\passengerdemand_result1.xlsx','B2:C101');
demandendlocation = xlsread('.\passengerdemand_result1.xlsx','D2:E101');
demandlocation=[demandstartlocation;demandendlocation];
demandtime=[demandstarttime;demandendtime];
distancematrix = generatedismatrix1(demandlocation,demandlocation);%----函数:生成一个N*2M的距离矩阵，行下标为各起点，列下表为各终点
timematrix = distancematrix*0.2;%速度30km/h,单位min
% vhclocation = zeros(vhcnum,1); %车辆位置
% vhctype = zeros(vhcnum,1);    %车辆类型
% vhccapacity = zeros(vhcnum,1); %车辆额定载客量
% vhcdepot = zeros(vhcnum,1);  %车辆所属场站
vhclocation = xlsread('.\vehcleinfomation.xlsx','A2:B16');
vhctype = xlsread('.\vehcleinfomation.xlsx','C2:C16');
vhccapacity = xlsread('.\vehcleinfomation.xlsx','D2:D16');
vhcdepot = xlsread('.\vehcleinfomation.xlsx','O2:O16');
vhcstarttime = xlsread('.\vehcleinfomation.xlsx','F2:G16');
vhcendtime = xlsread('.\vehcleinfomation.xlsx','H2:I16');
fixedcost = xlsread('.\vehcleinfomation.xlsx','J2:J16');%车辆固定成本
% ck = xlsread('C:\Users\lenovo\Desktop\定制公交线路规划程序\vehcleinfomation.xlsx','K2:K21');%车辆运行单位长度成本
cwk = xlsread('.\vehcleinfomation.xlsx','L2:L16');%车辆等待单位时间成本
ctk = xlsread('.\vehcleinfomation.xlsx','M2:M16');%车辆运行单位时间成本
% L0 = xlsread('C:\Users\lenovo\Desktop\定制公交线路规划程序\vehcleinfomation.xlsx','N2:N21');%固定成本所能运行的距离

%计算场站-需求timematrix矩阵
% vhcdemanddistancematrix = generatedismatrix1(vhclocation,demandlocation);%----函数:生成一个N*2M的距离矩阵，行下标为各起点，列下表为各终点
% vhcdemandtimematrix = vhcdemanddistancematrix*0.2;%速度30km/h,单位min
vhcindex = xlsread('.\vehcleinfomation.xlsx','O2:O16');%车辆-路网编号 O2:O16为车辆的起始场站编号
stopshortestdistance = xlsread('.\stop_shortestdistance','A1:CV100');%%推测为各点之间最短距离
stopindex1 = xlsread('.\passengerdemand_result1.xlsx','K2:K101');%输入需求上车站点编号
stopindex2 = xlsread('.\passengerdemand_result1.xlsx','L2:L101');%输入需求下车站点编号
demandstopindex = [stopindex1;stopindex2];%需求-路网编号

vhcdemandtimematrix = calvhcdemandtimematrix(vhcnum,demand,stopshortestdistance,vhcindex,demandstopindex);
[inisolution1,inireject1] = GenerateinisolutionRight0406(demand,demandstarttime,demandendtime,vhclocation,vhcstarttime,vhcendtime,timematrix,vhcdemandtimematrix,vhccapacity,fixedcost,cwk,ctk,TravelTimeMax);%------------函数：初始解生成（节约法）  
[inicost1,iniobjective1] = calculatetotalcost_test(inisolution1,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk);%-------------------函数：对解进行计算目标值


save OriginalData_TS0407.mat
%%%judgement函数是一样的