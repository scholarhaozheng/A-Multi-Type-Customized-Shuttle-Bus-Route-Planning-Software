clc;
clear all;
Obmat=[];
varmat=[];
Distance_Mat=[];
objectiveMat={};
load solution0802_NOT_concentrate_NO_TS
% % for i=1:vhcnum
% %     TsPoints=find(bestsolution{i,1}>2*demand);
% %     TsOrNot=isempty(TsPoints);
% %     if size(bestsolution{i,1},2)<=2&&TsOrNot==1
% %         bestsolution{i,1}=[];
% %     end
% % end
bestsolution{45,1}=[];
bestsolution{126,1}=[];
[obandvar1,var,Cost,Ob]=Generate_Costs(bestsolution,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk);
Obmat=[Obmat;Ob];
varmat=[varmat;var];
[distance,objective] = GeneratingTravelingDistance(bestsolution,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk,vhcdepot);
objectiveMat{1}=objective;
Distance_Mat(1,:)=distance;
load solution0802_NOT_concentrate_TS
for i=1:vhcnum
    TsPoints=find(bestsolution{i,1}>2*demand);
    TsOrNot=isempty(TsPoints);
    if size(bestsolution{i,1},2)<=2&&TsOrNot==1
        bestsolution{i,1}=[];
    end
end
[obandvar2,var,Cost,Ob]=Generate_Costs(bestsolution,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk);
Obmat=[Obmat;Ob];
varmat=[varmat;var];
[distance,objective] = GeneratingTravelingDistance(bestsolution,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk,vhcdepot);
objectiveMat{2}=objective;
Distance_Mat(2,:)=distance;
load solution0805_random_No_TS
[obandvar3,var,Cost,Ob]=Generate_Costs(bestsolution,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk);
Obmat=[Obmat;Ob];
varmat=[varmat;var];
[distance,objective] = GeneratingTravelingDistance(bestsolution,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk,vhcdepot);
objectiveMat{3}=objective;
Distance_Mat(3,:)=distance;
load solution0803_random_TS
[obandvar4,var,Cost,Ob]=Generate_Costs(bestsolution,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk);
Obmat=[Obmat;Ob];
varmat=[varmat;var];
[distance,objective] = GeneratingTravelingDistance(bestsolution,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk,vhcdepot);
objectiveMat{4}=objective;
Distance_Mat(4,:)=distance;
load solution0731_NoTS_concentrate
fixedcost = xlsread('.\vechleinfomation0730_1000.xlsx',1,['J2:J' num2str(indexv)]);%车辆固定成本
bestsolution{146,1}=[];
bestsolution{126,1}=[];
bestsolution{80,1}=[];
bestsolution{103,1}=[];
bestsolution{74,1}=[];
bestsolution{106,1}=[];
bestsolution{112,1}=[];

[obandvar5,var,Cost,Ob]=Generate_Costs(bestsolution,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk);
Obmat=[Obmat;Ob];
varmat=[varmat;var];
[distance,objective] = GeneratingTravelingDistance(bestsolution,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk,vhcdepot);
objectiveMat{5}=objective;
Distance_Mat(5,:)=distance;
load solution0731_concentrate
fixedcost = xlsread('.\vechleinfomation0730_1000.xlsx',1,['J2:J' num2str(indexv)]);%车辆固定成本
for i=1:vhcnum
    TsPoints=find(bestsolution{i,1}>2*demand);
    TsOrNot=isempty(TsPoints);
    if size(bestsolution{i,1},2)<=2&&TsOrNot==1
        bestsolution{i,1}=[];
    end
end
[obandvar6,var,Cost,Ob]=Generate_Costs(bestsolution,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk);
Obmat=[Obmat;Ob];
varmat=[varmat;var];
[distance,objective] = GeneratingTravelingDistance(bestsolution,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk,vhcdepot);
objectiveMat{6}=objective;
Distance_Mat(6,:)=distance;


xlswrite('Cost0515finalsolution.xlsx', Obmat, 'sheet1');
xlswrite('Cost0515finalsolution.xlsx', varmat, 'sheet2');
xlswrite('Cost0515finalsolution.xls', obandvar1, 'sheet1','A15');
xlswrite('Cost0515finalsolution.xls', obandvar2, 'sheet1','A16');
xlswrite('Cost0515finalsolution.xls', obandvar3, 'sheet1','A17');
xlswrite('Cost0515finalsolution.xls', obandvar4, 'sheet1','A18');
xlswrite('Cost0515finalsolution.xls', obandvar5, 'sheet1','A19');
xlswrite('Cost0515finalsolution.xls', obandvar6, 'sheet1','A20');

xlswrite('Cost0515finalsolution.xlsx', objectiveMat{1}', 'sheet3','A1:A500');
xlswrite('Cost0515finalsolution.xlsx', objectiveMat{2}', 'sheet3','B1:B500');
xlswrite('Cost0515finalsolution.xlsx', objectiveMat{3}', 'sheet3','C1:C500');
xlswrite('Cost0515finalsolution.xlsx', objectiveMat{4}', 'sheet3','D1:D500');
xlswrite('Cost0515finalsolution.xlsx', objectiveMat{5}', 'sheet3','E1:E500');
xlswrite('Cost0515finalsolution.xlsx', objectiveMat{6}', 'sheet3','F1:F500');







