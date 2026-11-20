clc;
clear all;
close all;
%load solution0802_not_concentrate_TS
%load solution0802_NOT_concentrate_NO_TS
%load solution0803_random_TS
%load solution0805_random_No_TS
string strrrr;
strrrr=[];
AAA=zeros(1,100);
strmat={};

load solution0731_NoTS_concentrate
fixedcost = xlsread('.\vechleinfomation0730_1000.xlsx',1,['J2:J' num2str(indexv)]);%车辆固定成本
bestsolution{146,1}=[];
bestsolution{126,1}=[];
bestsolution{80,1}=[];
bestsolution{103,1}=[];
bestsolution{74,1}=[];
bestsolution{106,1}=[];
bestsolution{112,1}=[];

% % % load solution0731_concentrate.mat
% % % fixedcost = xlsread('.\vechleinfomation0730_1000.xlsx',1,['J2:J' num2str(indexv)]);%车辆固定成本
% % % for i=1:vhcnum
% % %     TsPoints=find(bestsolution{i,1}>2*demand);
% % %     TsOrNot=isempty(TsPoints);
% % %     if size(bestsolution{i,1},2)<=2&&TsOrNot==1
% % %         bestsolution{i,1}=[];
% % %     end
% % % end
for i=1:vhcnum
    solution=bestsolution{i,1};
    if isempty(solution)
        continue
    end
    solution20=[vhcdepot(i,1),solution,vhcdepot(i,1)];
    strrrr=[];
    for j=1:size(solution20,2)
        if solution20(1,j)<=demand
            strrrr=[strrrr,num2str(solution20(1,j)),'^+,'];
        elseif solution20(1,j)<demand*2&&solution20(1,j)>demand
            strrrr=[strrrr,num2str(solution20(1,j)-demand),'^-,'];
        elseif solution20(1,j)==2*demand+1
            strrrr=[strrrr,'ts_1,'];
        elseif solution20(1,j)==2*demand+2
            strrrr=[strrrr,'ts_2,'];
        elseif solution20(1,j)==2*demand+3
            strrrr=[strrrr,'ts_3,'];
        elseif solution20(1,j)==2*demand+4
            strrrr=[strrrr,'de_1,'];
        elseif solution20(1,j)==2*demand+5
            strrrr=[strrrr,'de_2,'];
        elseif solution20(1,j)==2*demand+6
            strrrr=[strrrr,'de_3,'];
        elseif solution20(1,j)==2*demand+7
            strrrr=[strrrr,'de_4,'];
        elseif solution20(1,j)==2*demand+8
            strrrr=[strrrr,'de_5,'];
        end
    end
    strmat{i,1}= strrrr;
end

%xlswrite('routes_final_0805_random_No_TS.xlsx', strmat, 'sheet1');
%xlswrite('routes_final_0805_random_TS.xlsx', strmat, 'sheet1');
%xlswrite('routes_NOT_concentrate_TS.xlsx', strmat, 'sheet1');
%xlswrite('routes_final_0805_NOT_concentrate_NO_TS.xlsx', strmat, 'sheet1');
xlswrite('routes_final_0805_concentrate_No_TS.xlsx', strmat, 'sheet1');


