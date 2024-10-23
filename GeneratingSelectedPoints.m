clc;
clear all;
close all;
load solution0801_TS_NOT_concentrate.mat
served=[];
for i=1:vhcnum
    solution=bestsolution{i,1};
    if size(solution,2)>0
        served=[served,solution];
    end
end
served=served(served<=1000);
xlswrite('Selected0802.xlsx', served', 'sheet1')
