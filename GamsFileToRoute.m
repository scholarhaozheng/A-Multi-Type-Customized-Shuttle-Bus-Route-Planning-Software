clc;
clear all;
close all;
routes = xlsread('.\x0802_7.xlsx',1,['A1:AL38']);
vehicles_steps=routes(:,1);
% % % vehicles_steps_zeros(:,1)=routes(:,1);
% % % vehicles_steps_zeros(:,2)=routes(:,2);
vehicles=unique(vehicles_steps);
route=zeros(35,30);
for i=1:35
    iroute=[];
    pos=find(vehicles_steps==i);
    if isempty(pos)
        continue
    end
    vehicle_routes=routes(pos,:);
    vehicles_steps_zeros=zeros(size(routes,1),size(routes,2));
    vehicles_steps_zeros(pos,:)=vehicle_routes;
    vehicles_steps_zeros1=vehicles_steps_zeros;
    vehicles_steps_zeros(1,:)=routes(1,:);
    now=451;
    iroute=[iroute,now];
    [nowpos,~]=find(vehicles_steps_zeros1==now);
    while now~=45221
        nowposition=vehicles_steps_zeros(nowpos,:);
        nowposition=nowposition(1,3:end);
        pos1=find(nowposition==1)+2;
        now=vehicles_steps_zeros(1,pos1);
        iroute=[iroute,now];
        [nowpos,~]=find(vehicles_steps_zeros1(:,2)==now);
        length=size(iroute,2);
    end
    iroute=[iroute,zeros(1,30-length)];
    route(i,:)=iroute;
end
xlswrite('x0802_7_ori_d_final_time.xlsx', route, 'sheet1');

