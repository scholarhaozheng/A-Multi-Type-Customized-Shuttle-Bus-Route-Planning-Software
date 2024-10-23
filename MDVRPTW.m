tic
clear all;
clc;

TravelTimeMax=500;
maxiteration = 100;%---------------停止规则为到达一定迭代步数即停止
vhcnum = 30;%车辆数量
demand = 10;%需求数量
neignum = 10;%邻居数量
tabulength = 30;%可以变化长度，但要放在大循环里------------------------------------------------禁忌长度
alpha1=33;
alpha2=9;
alpha3=13;
r=0.1;
tsNum=1;
depotNum=1;
TS=[2*demand+1];
op=2;
tsop=3;
SetTsMax=16;
EachOptionMax=8;
lambda=20;
demandv=demand+1;
demandstarttime = xlsread('.\gams10.xlsx',1,['F2:G' num2str(demandv)]);
demandendtime = xlsread('.\gams10.xlsx',1,['H2:I' num2str(demandv)]);
demandstartlocation = xlsread('.\gams10.xlsx',1,['B2:C' num2str(demandv)]);
demandendlocation = xlsread('.\gams10.xlsx',1,['D2:E' num2str(demandv)]);
tsv1=demandv+1;
tsv2=tsv1+tsNum-1;
depv1=tsv2+1;
depv2=depv1+depotNum-1;
tsLocation=xlsread('.\gams10.xlsx',1,['B' num2str(tsv1) ':C' num2str(tsv2)]);
depLocation=xlsread('.\gams10.xlsx',1,['B' num2str(depv1) ':C' num2str(depv2)]);
demandlocation=[demandstartlocation;demandendlocation];
allLocation=[demandlocation;tsLocation;depLocation];
demandtime=[demandstarttime;demandendtime];
distancematrix = generatedismatrix1(allLocation,allLocation);%----函数:生成一个N*2M的距离矩阵，行下标为各起点，列下表为各终点
timematrix = distancematrix*2;%速度0.5km/min,单位min
% vhclocation = zeros(vhcnum,1); %车辆位置
% vhctype = zeros(vhcnum,1);    %车辆类型
% vhccapacity = zeros(vhcnum,1); %车辆额定载客量
% vhcdepot = zeros(vhcnum,1);  %车辆所属场站
indexv=vhcnum+1;
vhcdepot = xlsread('.\vechleinfomation0731gams.xlsx',1,['O2:O' num2str(indexv)]);%车辆-路网编号 O2:O16为车辆的起始场站编号
for i=1:vhcnum
    vhclocation(i,1) = allLocation(vhcdepot(i,1),1);
    vhclocation(i,2) = allLocation(vhcdepot(i,1),2);
end
vhctype = xlsread('.\vechleinfomation0731gams.xlsx',1,['C2:C' num2str(indexv)]);
vhccapacity = xlsread('.\vechleinfomation0731gams.xlsx',1,['D2:D' num2str(indexv)]);
vhcstarttime = xlsread('.\vechleinfomation0731gams.xlsx',1,['F2:G' num2str(indexv)]);
vhcendtime = xlsread('.\vechleinfomation0731gams.xlsx',1,['H2:I' num2str(indexv)]);
fixedcost = xlsread('.\vechleinfomation0731gams.xlsx',1,['J2:J' num2str(indexv)]);%车辆固定成本
% ck = xlsread('C:\Users\lenovo\Desktop\定制公交线路规划程序\vechleinfomation0731gamsairport.xlsx','K2:K21');%车辆运行单位长度成本
cwk = xlsread('.\vechleinfomation0731gams.xlsx',1,['L2:L' num2str(indexv)]);%车辆等待单位时间成本
ctk = xlsread('.\vechleinfomation0731gams.xlsx',1,['M2:M' num2str(indexv)]);%车辆运行单位时间成本
depotendtime=[demand*2+tsNum+1,780;];
% L0 = xlsread('C:\Users\lenovo\Desktop\定制公交线路规划程序\vechleinfomation0731gamsairport.xlsx','N2:N21');%固定成本所能运行的距离

%计算场站-需求timematrix矩阵
% vhcdemanddistancematrix = generatedismatrix1(vhclocation,demandlocation);%----函数:生成一个N*2M的距离矩阵，行下标为各起点，列下表为各终点
% vhcdemandtimematrix = vhcdemanddistancematrix*0.2;%速度30km/h,单位min
vhcdemandtimematrix = calvhcdemandtimematrix(vhcnum,demand,tsNum,depotNum,timematrix,vhcdepot);
[inisolution1,inireject1] = GenerateinisolutionRight0410(demand,demandstarttime,demandendtime,vhclocation,vhcstarttime,vhcendtime,timematrix,vhcdemandtimematrix,vhccapacity,fixedcost,cwk,ctk,TravelTimeMax,op,tsop);%------------函数：初始解生成（节约法）
[inicost1,~] = calculatetotalcost_test(inisolution1,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk);%-------------------函数：对解进行计算目标值

%%save initial0802_not_concentrate.mat
tabulist = ones(tabulength,7);

His_TsRelationship=cell(maxiteration,1);
His_solution=cell(maxiteration,1);
His_no_ts_solution=cell(maxiteration,1);

clc;

bestsolution = inisolution1;%最优解为初始解
bestcost = inicost1;%最优目标为当前目标
currentsolution = inisolution1;%当前解为初始解
currentcost = inicost1;%当前目标为初始目标
tablesolutionneig = zeros(neignum,7);%邻域表，通过函数生成
tablecostneig = zeros(neignum,1);%邻域的目标值
bestsolutionneig = zeros(1,7);
bestsolutiontabuneig = zeros(1,7);
%启动迭代
bestcosttabuneig = inicost1;
bestcostneig = inicost1;
His_best=zeros(maxiteration,1);%记录每次迭代的最优解
CurrentCost=zeros(maxiteration,1);
CurrentNoTsSolution=bestsolution;
CurrentNoTsSolutionCell=cell(maxiteration,1);
TsRelationship=zeros(vhcnum,2);
%%objective = zeros(maxiteration,11);
omega_des=0.2*ones(1,5);
omega_rep=0.333333333*ones(1,3);
omega_des_add=zeros(1,5);
omega_rep_add=zeros(1,3);
omega_des_time=zeros(1,5);
omega_rep_time=zeros(1,3);
Choose_history_des=zeros(maxiteration,neignum);
Choose_history_rep=zeros(maxiteration,neignum);
for i = 1:maxiteration
    CurrentCost(i,1)=currentcost;
    display(['%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%']);
    display(['iteration of main function is ' num2str(i)]);
    tabletransitsolution=cell(neignum,1);
    TsRelationshipsCell=cell(neignum,1);
    NoTsSolutionNeigCell=cell(1,neignum);
    TsOrNot=zeros(1,neignum);
    notscostneig=zeros(neignum,1);
    for j = 1:neignum %生成邻域解
        if i/lambda-ceil(i/lambda)==0
            omega_des=0.2*ones(1,5);
            omega_rep=0.333333333*ones(1,3);
            omega_des_add=zeros(1,5);
            omega_rep_add=zeros(1,3);
            omega_des_time=zeros(1,5);
            omega_rep_time=zeros(1,3);
        end
        desORrep=1;
        [ des_option ] = GeneratingOperatorsChoice( i,lambda,desORrep,omega_des);
        desORrep=2;
        [ rep_option ] = GeneratingOperatorsChoice( i,lambda,desORrep,omega_rep);
        omega_des_time(1,des_option)=omega_des_time(1,des_option)+1;
        omega_rep_time(1,rep_option)=omega_rep_time(1,rep_option)+1;
        Choose_history_des(i,j)=des_option;
        Choose_history_rep(i,j)=rep_option;
        display(['——————————————————————————']);
                display(['neighbor ' num2str(j) ' is using ' num2str(des_option)  ' des_option, and ' num2str(rep_option) ' rep_option']);
                [TsRelationNewWithTS,TsRelationNew,tablesolutionneigj, transitsolution_NoTs, BestAlloverSolutionTs,BestAllOverCostTs] = DestroyandRepair_swap_2opt_func0803_edit_rep_1(currentsolution,CurrentNoTsSolutionCell,TsRelationship,demand,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,TS,depotendtime,vhccapacity,fixedcost,cwk,ctk,vhcdepot,des_option,rep_option,TravelTimeMax,op,tsop,SetTsMax,EachOptionMax,i,His_TsRelationship);
                [NoTsCost,~] = calculatetotalcost_test(transitsolution_NoTs,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk);
                %%%%%%transitsolution为已经插入下车点的解；tablesolutionneig = [1,a,e,b,f];
                %%%%%%best solution neig 和best solution tabu neig是0
                NoTsSolutionNeigCell{1,j}=transitsolution_NoTs;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                if NoTsCost<=BestAllOverCostTs%%%%%不带TS的情况更优
                    tablecostneig(j,1)=NoTsCost;
                    tabletransitsolution{j,:}=transitsolution_NoTs;
                    display(['NoTsCost= ' num2str(NoTsCost) ',  BestAllOverCostTs= ' num2str(BestAllOverCostTs)  ]);
                    display(['Solution without Ts point is better']);
                    TsRelationshipsCell{j,1}=TsRelationNew;
                    TsOrNot(1,j)=0;
                else
                    display(['NoTsCost= ' num2str(NoTsCost) ',  BestAllOverCostTs= ' num2str(BestAllOverCostTs)  ]);
                    tablecostneig(j,1)=BestAllOverCostTs;
                    tabletransitsolution{j,:}=BestAlloverSolutionTs;
                    display(['Solution with Ts point is better']);
                    TsRelationshipsCell{j,1}=TsRelationNewWithTS;
                    TsOrNot(1,j)=1;
                end
                %%[tablecostneig(j,1),~] = calculatetotalcost(transitsolution,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk);
                notscostneig(j,1)= NoTsCost;
        %%tablesolutionneig = [1 OR 2,a,e,insertpositiona,b,f,insertpositionb];
        tablesolutionneig(j,:) = tablesolutionneigj;
    end
    solutionneigtabumode = zeros(neignum,1);%邻域禁忌状态
    for j = 1:neignum
        for k = 1:tabulength
            if tablesolutionneig(j,:) == tabulist(k,1:7) %如果邻域解被禁忌，状态为1
                solutionneigtabumode(j,1) = 1;
                break
            end
        end
    end
    index=0;
    tabuindex=0;
    bestcostneig=9999999999;
    for j = 1:neignum %分别遍历邻域表和禁忌表的最优解
        if solutionneigtabumode(j,1) == 0 %比较禁忌状态为0的邻域解，若目标函数小于最优邻域解，则替换最优邻域解
            if tablecostneig(j,1) < bestcostneig
                bestsolutionneig = tablesolutionneig(j,:);
                bestcostneig = tablecostneig(j,1);
                index = j;
            end
        else
            if tablecostneig(j,1) < bestcosttabuneig %比较禁忌状态为1的邻域解，若目标函数小于最优禁忌解，则替换最优禁忌解
                bestsolutiontabuneig = tablesolutionneig(j,:);
                bestcosttabuneig = tablecostneig(j,1);
                tabuindex = j;
            end
        end
    end
    display(['……………………………………………………………………']);
    display(['Bestcosttabuneig: ' num2str(bestcosttabuneig) ', tabuindex: ' num2str(tabuindex)]);
    display(['Bestcostneig: ' num2str(bestcostneig) ', index: ' num2str(index) ', TsOrNot is ' num2str(TsOrNot(1,index))]);
% %     load debug0423.mat
% %     if TsOrNot(1,index)==1
% %         display(['let me see whats wrong'])
% %         save debug0423.mat
% %         pause(100000)
% %     end
    if bestcosttabuneig < bestcost %若最优禁忌解小于最优解，则解禁
        tabuuseful=1;
        bestcost = bestcosttabuneig;
        bestsolution = tabletransitsolution{tabuindex,:};
        CurrentNoTsSolution=NoTsSolutionNeigCell{1,tabuindex};
        TsRelationship=TsRelationshipsCell{tabuindex,1};
        currentsolution = bestsolution;
        currentcost = bestcost;
        TabuAdd = [bestsolutiontabuneig(1,1) bestsolutiontabuneig(1,5:7) bestsolutiontabuneig(1,2:4)];
        tabulist = [tabulist(2:tabulength,1:7);TabuAdd];
        display(['bestcosttabuneig < bestcost, ' ]);
        omega_des_add(1,des_option)=omega_des_add(1,des_option)+alpha1;
        omega_rep_add(1,rep_option)=omega_rep_add(1,rep_option)+alpha1;
    else
        %bestcostneig为最优邻域解
        currentsolution = tabletransitsolution{index,:};
        CurrentNoTsSolution=NoTsSolutionNeigCell{1,index};
        TsRelationship=TsRelationshipsCell{index,1};
        TabuAdd = [bestsolutionneig(1,1) bestsolutionneig(1,5:7) bestsolutionneig(1,2:4)];
        tabulist = [tabulist(2:tabulength,1:7);TabuAdd];
        if currentcost<bestcostneig
            omega_des_add(1,des_option)=omega_des_add(1,des_option)+alpha3;
            omega_rep_add(1,rep_option)=omega_rep_add(1,rep_option)+alpha3;
        else
            omega_des_add(1,des_option)=omega_des_add(1,des_option)+alpha2;
            omega_rep_add(1,rep_option)=omega_rep_add(1,rep_option)+alpha2;
        end
        currentcost = bestcostneig;
        if bestcostneig < bestcost %%%%%若最优邻域解小于历史最优解
            bestcost = currentcost;
            bestsolution = currentsolution;
            omega_des_add(1,des_option)=omega_des_add(1,des_option)+alpha1;
            omega_rep_add(1,rep_option)=omega_rep_add(1,rep_option)+alpha1;
        end
    end
    CurrentNoTsSolutionCell{i,1}=CurrentNoTsSolution;
    His_best(i,1)=bestcost;
    His_TsRelationship{i,1}=TsRelationship;
    His_solution{i,1}=currentsolution;
    His_no_ts_solution{i,1}=CurrentNoTsSolution;
    if i/lambda-ceil(i/lambda)==0
        for jjjj=1:5
            if omega_des_time(1,jjjj)==0
                omega_des_add(1,jjjj)=0;
                continue
            end
            omega_des_add(1,jjjj)=omega_des_add(1,jjjj)/omega_des_time(1,jjjj)*5;
        end
        for jjjj=1:3
            if omega_rep_time(1,jjjj)==0
                omega_rep_add(1,jjjj)=0;
                continue
            end
            omega_rep_add(1,jjjj)=omega_rep_add(1,jjjj)/omega_rep_time(1,jjjj)*10/3;
        end
        omega_des=omega_des*(1-r)+omega_des_add*r;
        omega_rep=omega_rep*(1-r)+omega_rep_add*r;
        omega_des_time=zeros(1,5);
        omega_rep_time=zeros(1,3);
    end
end
% objecrtive_change_tabulength(mm,1)=bestcost;
% end
%画图
% hand2=plot(1:maxiteration,best(:,1));
% set(hand2,'color','r','linestyle','-','linewidth',0.5,'markersize',6)
% xlabel('iteration');ylabel('cost');xlim([1 maxiteration]);
% % legend('currentcost','bestcost');
% legend('bestcost');
% hold off
% box off ;
%% ==============作图==============
% % figure(1)   %作最短路径图
% % for j=1:vhcnum
% %     Shortest_Route=bestsolution{j,1};
% %     Shortest_Route=[Shortest_Route Shortest_Route(1)];
% %     plot([allLocation(Shortest_Route,1)],[allLocation(Shortest_Route,2)],'o-');
% %     hold on
% % end
% % grid on
% % for i = 1:size(allLocation,1)
% %     text(allLocation(i,1),allLocation(i,2),['   ' num2str(i)]);
% % end
% % xlabel('城市横坐标'); ylabel('城市纵坐标'); 
bestsolution
toc
for i=1:vhcnum
    if i==1
        dlmwrite('test.csv',bestsolution{i,1},'delimiter',',');
    else
        dlmwrite('test.csv',bestsolution{i,1},'delimiter',',','-append');
    end
end

%save %solution0802_not_concentrate_TS.mat 历时 3635.088934 秒。
%save solution0802_not_concentrate_NOTS.mat
save gams10.mat

