tic
clear all;
clc;

% % % TravelTimeMax=500;
% % % maxiteration = 1; % --------------- Stop criteria: stop after reaching a certain number of iterations
% % % vhcnum = 170; % Number of vehicles
% % % demand = 476; % Demand quantity
% % % neignum = 10; % Number of neighbors
% % % tabulength = 30; % Can vary length, but must be placed in the main loop --------------- Tabu list length
% % % alpha1=33;
% % % alpha2=9;
% % % alpha3=13;
% % % r=0.1;
% % % tsNum=3;
% % % depotNum=5;
% % % TS=[2*demand+1,2*demand+2,2*demand+3];
% % % op=2;
% % % tsop=3;
% % % SetTsMax=16;
% % % EachOptionMax=8;
% % % lambda=20;
% % % demandv=demand+1;
% % % demandstarttime = xlsread('.\result0731_right.xlsx',1,['F2:G' num2str(demandv)]);
% % % demandendtime = xlsread('.\result0731_right.xlsx',1,['H2:I' num2str(demandv)]);
% % % demandstartlocation = xlsread('.\result0731_right.xlsx',1,['B2:C' num2str(demandv)]);
% % % demandendlocation = xlsread('.\result0731_right.xlsx',1,['D2:E' num2str(demandv)]);
% % % tsv1=demandv+1;
% % % tsv2=tsv1+tsNum-1;
% % % depv1=tsv2+1;
% % % depv2=depv1+depotNum-1;
% % % tsLocation=xlsread('.\result0731_right.xlsx',1,['B' num2str(tsv1) ':C' num2str(tsv2)]);
% % % depLocation=xlsread('.\result0731_right.xlsx',1,['B' num2str(depv1) ':C' num2str(depv2)]);
% % % demandlocation=[demandstartlocation;demandendlocation];
% % % allLocation=[demandlocation;tsLocation;depLocation];
% % % demandtime=[demandstarttime;demandendtime];
% % % distancematrix = generatedismatrix1(allLocation,allLocation); % ---- Function: generate a distance matrix of size N*2M, where rows correspond to starting points and columns correspond to destination points
% % % timematrix = distancematrix*2; % Speed: 0.5 km/min, unit: minutes
% % % % vhclocation = zeros(vhcnum,1); % Vehicle locations
% % % % vhctype = zeros(vhcnum,1);    % Vehicle types
% % % % vhccapacity = zeros(vhcnum,1); % Vehicle capacity
% % % % vhcdepot = zeros(vhcnum,1);  % Vehicle depot assignment
% % % indexv=vhcnum+1;
% % % vhcdepot = xlsread('.\vechleinfomation0730_1000.xlsx',1,['O2:O' num2str(indexv)]); % Vehicle network id: O2:O16 represents starting depot id for vehicles
% % % for i=1:vhcnum
% % %     vhclocation(i,1) = allLocation(vhcdepot(i,1),1);
% % %     vhclocation(i,2) = allLocation(vhcdepot(i,1),2);
% % % end
% % % vhctype = xlsread('.\vechleinfomation0730_1000.xlsx',1,['C2:C' num2str(indexv)]);
% % % vhccapacity = xlsread('.\vechleinfomation0730_1000.xlsx',1,['D2:D' num2str(indexv)]);
% % % vhcstarttime = xlsread('.\vechleinfomation0730_1000.xlsx',1,['F2:G' num2str(indexv)]);
% % % vhcendtime = xlsread('.\vechleinfomation0730_1000.xlsx',1,['H2:I' num2str(indexv)]);
% % % fixedcost = xlsread('.\vechleinfomation0730_1000.xlsx',1,['J2:J' num2str(indexv)]); % Fixed vehicle cost
% % % % ck = xlsread('C:\Users\lenovo\Desktop\custom_bus_routing_program\vechleinfomation0730_1000airport.xlsx','K2:K21'); % Vehicle operating cost per unit distance
% % % cwk = xlsread('.\vechleinfomation0730_1000.xlsx',1,['L2:L' num2str(indexv)]); % Vehicle waiting cost per unit time
% % % ctk = xlsread('.\vechleinfomation0730_1000.xlsx',1,['M2:M' num2str(indexv)]); % Vehicle operating cost per unit time
% % % depotendtime=[demand*2+tsNum+1,780;demand*2+tsNum+2,780;demand*2+tsNum+3,780;demand*2+tsNum+4,780;demand*2+tsNum+5,780;];
% % % % L0 = xlsread('C:\Users\lenovo\Desktop\custom_bus_routing_program\vechleinfomation0730_1000airport.xlsx','N2:N21'); % Distance that can be run with fixed cost
% % % 
% % % % Calculate depot-to-demand time matrix
% % % % vhcdemanddistancematrix = generatedismatrix1(vhclocation,demandlocation); % ---- Function: generate a distance matrix of size N*2M, where rows correspond to starting points and columns correspond to destination points
% % % % vhcdemandtimematrix = vhcdemanddistancematrix*0.2; % Speed: 30 km/h, unit: minutes
% % % vhcdemandtimematrix = calvhcdemandtimematrix(vhcnum,demand,tsNum,depotNum,timematrix,vhcdepot);
% % % [inisolution1,inireject1] = GenerateinisolutionRight0410(demand,demandstarttime,demandendtime,vhclocation,vhcstarttime,vhcendtime,timematrix,vhcdemandtimematrix,vhccapacity,fixedcost,cwk,ctk,TravelTimeMax,op,tsop); % ------------ Function: Initial solution generation (savings method)
% % % [inicost1,~] = calculatetotalcost_test(inisolution1,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk); % ------------------- Function: calculate total cost of the solution
% % % 
% % % TravelTimeMax=500;
% % % maxiteration = 1; % --------------- Stop criteria: stop after reaching a certain number of iterations
% % % vhcnum = 170; % Number of vehicles
% % % demand = 1000; % Demand quantity
% % % neignum = 10; % Number of neighbors
% % % tabulength = 30; % Can vary length, but must be placed in the main loop --------------- Tabu list length
% % % alpha1=33;
% % % alpha2=9;
% % % alpha3=13;
% % % r=0.1;
% % % tsNum=3;
% % % depotNum=5;
% % % TS=[2*demand+1,2*demand+2,2*demand+3];
% % % op=2;
% % % tsop=3;
% % % SetTsMax=16;
% % % EachOptionMax=8;
% % % lambda=20;
% % % demandv=demand+1;
% % % demandstarttime = xlsread('.\result0731_right.xlsx',1,['F2:G' num2str(demandv)]);
% % % demandendtime = xlsread('.\result0731_right.xlsx',1,['H2:I' num2str(demandv)]);
% % % demandstartlocation = xlsread('.\result0731_right.xlsx',1,['B2:C' num2str(demandv)]);
% % % demandendlocation = xlsread('.\result0731_right.xlsx',1,['D2:E' num2str(demandv)]);
% % % tsv1=demandv+1;
% % % tsv2=tsv1+tsNum-1;
% % % depv1=tsv2+1;
% % % depv2=depv1+depotNum-1;
% % % tsLocation=xlsread('.\result0731_right.xlsx',1,['B' num2str(tsv1) ':C' num2str(tsv2)]);
% % % depLocation=xlsread('.\result0731_right.xlsx',1,['B' num2str(depv1) ':C' num2str(depv2)]);
% % % demandlocation=[demandstartlocation;demandendlocation];
% % % allLocation=[demandlocation;tsLocation;depLocation];
% % % demandtime=[demandstarttime;demandendtime];
% % % distancematrix = generatedismatrix1(allLocation,allLocation); % ---- Function: generate a distance matrix of size N*2M, where rows correspond to starting points and columns correspond to destination points
% % % timematrix = distancematrix*2; % Speed: 0.5 km/min, unit: minutes
% % % % vhclocation = zeros(vhcnum,1); % Vehicle locations
% % % % vhctype = zeros(vhcnum,1);    % Vehicle types
% % % % vhccapacity = zeros(vhcnum,1); % Vehicle capacity
% % % % vhcdepot = zeros(vhcnum,1);  % Vehicle depot assignment
% % % indexv=vhcnum+1;
% % % vhcdepot = xlsread('.\vechleinfomation0730_1000.xlsx',1,['O2:O' num2str(indexv)]); % Vehicle network id: O2:O16 represents starting depot id for vehicles
% % % for i=1:vhcnum
% % %     vhclocation(i,1) = allLocation(vhcdepot(i,1),1);
% % %     vhclocation(i,2) = allLocation(vhcdepot(i,1),2);
% % % end
% % % vhctype = xlsread('.\vechleinfomation0730_1000.xlsx',1,['C2:C' num2str(indexv)]);
% % % vhccapacity = xlsread('.\vechleinfomation0730_1000.xlsx',1,['D2:D' num2str(indexv)]);
% % % vhcstarttime = xlsread('.\vechleinfomation0730_1000.xlsx',1,['F2:G' num2str(indexv)]);
% % % vhcendtime = xlsread('.\vechleinfomation0730_1000.xlsx',1,['H2:I' num2str(indexv)]);
% % % fixedcost = xlsread('.\vechleinfomation0730_1000.xlsx',1,['J2:J' num2str(indexv)]); % Fixed vehicle cost
% % % % ck = xlsread('C:\Users\lenovo\Desktop\custom_bus_routing_program\vechleinfomation0730_1000airport.xlsx','K2:K21'); % Vehicle operating cost per unit distance
% % % cwk = xlsread('.\vechleinfomation0730_1000.xlsx',1,['L2:L' num2str(indexv)]); % Vehicle waiting cost per unit time
% % % ctk = xlsread('.\vechleinfomation0730_1000.xlsx',1,['M2:M' num2str(indexv)]); % Vehicle operating cost per unit time
% % % depotendtime=[demand*2+tsNum+1,780;demand*2+tsNum+2,780;demand*2+tsNum+3,780;demand*2+tsNum+4,780;demand*2+tsNum+5,780;];
% % % % L0 = xlsread('C:\Users\lenovo\Desktop\custom_bus_routing_program\vechleinfomation0730_1000airport.xlsx','N2:N21'); % Distance that can be run with fixed cost
% % % 
% % % % Calculate depot-to-demand time matrix
% % % % vhcdemanddistancematrix = generatedismatrix1(vhclocation,demandlocation); % ---- Function: generate a distance matrix of size N*2M, where rows correspond to starting points and columns correspond to destination points
% % % % vhcdemandtimematrix = vhcdemanddistancematrix*0.2; % Speed: 30 km/h, unit: minutes
% % % vhcdemandtimematrix = calvhcdemandtimematrix(vhcnum,demand,tsNum,depotNum,timematrix,vhcdepot);
% % % [inisolution1,inireject1] = GenerateinisolutionRight0410(demand,demandstarttime,demandendtime,vhclocation,vhcstarttime,vhcendtime,timematrix,vhcdemandtimematrix,vhccapacity,fixedcost,cwk,ctk,TravelTimeMax,op,tsop); % ------------ Function: Initial solution generation (savings method)
% % % [inicost1,~] = calculatetotalcost_test(inisolution1,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk); % ------------------- Function: calculate total cost of the solution
% % % 

load initial0805_concentrate
tabulist = ones(tabulength,7);

His_TsRelationship = cell(maxiteration,1);
His_solution = cell(maxiteration,1);
His_no_ts_solution = cell(maxiteration,1);

clc;

bestsolution = inisolution1; % Best solution is the initial solution
bestcost = inicost1; % Best objective value is the current objective
currentsolution = inisolution1; % Current solution is the initial solution
currentcost = inicost1; % Current objective value is the initial objective
tablesolutionneig = zeros(neignum,7); % Neighborhood solution table, generated by function
tablecostneig = zeros(neignum,1); % Objective values of the neighborhood
bestsolutionneig = zeros(1,7);
bestsolutiontabuneig = zeros(1,7);
% Start iteration
bestcosttabuneig = inicost1;
bestcostneig = inicost1;
His_best = zeros(maxiteration,1); % Record the best solution of each iteration
CurrentCost = zeros(maxiteration,1);
CurrentNoTsSolution = bestsolution;
CurrentNoTsSolutionCell = cell(maxiteration,1);
TsRelationship = zeros(vhcnum,2);
%%objective = zeros(maxiteration,11);
omega_des = 0.2*ones(1,5);
omega_rep = 0.333333333*ones(1,3);
omega_des1 = 0.2*ones(1,5);
omega_rep1 = 0.333333333*ones(1,3);
Choose_history_des = zeros(maxiteration,neignum);
Choose_history_rep = zeros(maxiteration,neignum);
for i = 1:maxiteration
    CurrentCost(i,1) = currentcost;
    display(['%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%']);
    display(['iteration of main function is ' num2str(i)]);
    tabletransitsolution = cell(neignum,1);
    TsRelationshipsCell = cell(neignum,1);
    NoTsSolutionNeigCell = cell(1,neignum);
    TsOrNot = zeros(1,neignum);
    notscostneig = zeros(neignum,1);
    for j = 1:neignum % Generate neighborhood solution
        lambda = 10;
        if i/lambda - ceil(i/lambda) == 0
            omega_des = 0.2*ones(1,5);
            omega_rep = 0.333333333*ones(1,3);
        end
        omega_des1 = omega_des;
        omega_rep1 = omega_rep;
        desORrep = 1;
        [des_option] = GeneratingOperatorsChoice(i, lambda, desORrep, omega_des);
        desORrep = 2;
        [rep_option] = GeneratingOperatorsChoice(i, lambda, desORrep, omega_rep);
        Choose_history_des(i,j) = des_option;
        Choose_history_rep(i,j) = rep_option;
        display(['¡ª¡ª¡ª¡ª¡ª¡ª¡ª¡ª¡ª¡ª¡ª¡ª¡ª¡ª¡ª¡ª¡ª¡ª¡ª¡ª¡ª¡ª¡ª¡ª¡ª¡ª']);
        display(['neighbor ' num2str(j) ' is using ' num2str(des_option) ' des_option, and ' num2str(rep_option) ' rep_option']);
        [TsRelationNewWithTS, TsRelationNew, tablesolutionneigj, transitsolution_NoTs, BestAlloverSolutionTs, BestAllOverCostTs] = DestroyandRepair_swap_2opt_func0803_edit_rep_1(currentsolution, CurrentNoTsSolutionCell, TsRelationship, demand, vhcstarttime, vhcendtime, demandstarttime, demandendtime, timematrix, vhcdemandtimematrix, TS, depotendtime, vhccapacity, fixedcost, cwk, ctk, vhcdepot, des_option, rep_option, TravelTimeMax, op, tsop, SetTsMax, EachOptionMax, i, His_TsRelationship);
        [NoTsCost, ~] = calculatetotalcost_test(transitsolution_NoTs, demand, vhccapacity, demandstarttime, demandendtime, vhcstarttime, timematrix, vhcdemandtimematrix, fixedcost, cwk, ctk);
        %%%%%% transitsolution is the solution with drop-off points inserted; tablesolutionneig = [1,a,e,b,f];
        %%%%%% best solution neig and best solution tabu neig are initially zero
        NoTsSolutionNeigCell{1,j} = transitsolution_NoTs; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if NoTsCost <= BestAllOverCostTs %%%%% Case without TS is better
            tablecostneig(j,1) = NoTsCost;
            tabletransitsolution{j,:} = transitsolution_NoTs;
            display(['NoTsCost= ' num2str(NoTsCost) ',  BestAllOverCostTs= ' num2str(BestAllOverCostTs)]);
            display(['Solution without Ts point is better']);
            TsRelationshipsCell{j,1} = TsRelationNew;
            TsOrNot(1,j) = 0;
        else
            display(['NoTsCost= ' num2str(NoTsCost) ',  BestAllOverCostTs= ' num2str(BestAllOverCostTs)]);
            tablecostneig(j,1) = BestAllOverCostTs;
            tabletransitsolution{j,:} = BestAlloverSolutionTs;
            display(['Solution with Ts point is better']);
            TsRelationshipsCell{j,1} = TsRelationNewWithTS;
            TsOrNot(1,j) = 1;
        end
        % [tablecostneig(j,1),~] = calculatetotalcost(transitsolution, demand, vhccapacity, demandstarttime, demandendtime, vhcstarttime, timematrix, vhcdemandtimematrix, fixedcost, cwk, ctk);
        notscostneig(j,1) = NoTsCost;
        % tablesolutionneig = [1 OR 2,a,e,insertpositiona,b,f,insertpositionb];
        tablesolutionneig(j,:) = tablesolutionneigj;
    end
    solutionneigtabumode = zeros(neignum,1); % Tabu status of neighborhood solutions
    for j = 1:neignum
        for k = 1:tabulength
            if tablesolutionneig(j,:) == tabulist(k,1:7) % If the neighborhood solution is tabu, set status to 1
                solutionneigtabumode(j,1) = 1;
                break
            end
        end
    end
    index = 0;
    tabuindex = 0;
    bestcostneig = 9999999999;
    for j = 1:neignum % Iterate over the neighborhood and tabu tables to find the best solution
        if solutionneigtabumode(j,1) == 0 % For non-tabu neighborhood solution, if its objective is less than the current best, update the best
            if tablecostneig(j,1) < bestcostneig
                bestsolutionneig = tablesolutionneig(j,:);
                bestcostneig = tablecostneig(j,1);
                index = j;
            end
        else
            if tablecostneig(j,1) < bestcosttabuneig % For tabu neighborhood solution, if its objective is less than the current best tabu solution, update it
                bestsolutiontabuneig = tablesolutionneig(j,:);
                bestcosttabuneig = tablecostneig(j,1);
                tabuindex = j;
            end
        end
    end
    display(['¡­¡­¡­¡­¡­¡­¡­¡­¡­¡­¡­¡­¡­¡­¡­¡­¡­¡­¡­¡­¡­¡­¡­¡­¡­¡­']);
    display(['Bestcosttabuneig: ' num2str(bestcosttabuneig) ', tabuindex: ' num2str(tabuindex)]);
    display(['Bestcostneig: ' num2str(bestcostneig) ', index: ' num2str(index) ', TsOrNot is ' num2str(TsOrNot(1,index))]);
    if bestcosttabuneig < bestcost % If the best tabu solution is better than the best overall solution, then override
        tabuuseful = 1;
        bestcost = bestcosttabuneig;
        bestsolution = tabletransitsolution{tabuindex,:};
        CurrentNoTsSolution = NoTsSolutionNeigCell{1,tabuindex};
        TsRelationship = TsRelationshipsCell{tabuindex,1};
        currentsolution = bestsolution;
        currentcost = bestcost;
        TabuAdd = [bestsolutiontabuneig(1,1) bestsolutiontabuneig(1,5:7) bestsolutiontabuneig(1,2:4)];
        tabulist = [tabulist(2:tabulength,1:7); TabuAdd];
        display(['bestcosttabuneig < bestcost, ']);
        omega_des1(1,des_option) = omega_des1(1,des_option) + alpha1;
        omega_rep1(1,rep_option) = omega_rep1(1,rep_option) + alpha1;
    else
        % bestcostneig is the best neighborhood solution
        currentsolution = tabletransitsolution{index,:};
        CurrentNoTsSolution = NoTsSolutionNeigCell{1,index};
        TsRelationship = TsRelationshipsCell{index,1};
        TabuAdd = [bestsolutionneig(1,1) bestsolutionneig(1,5:7) bestsolutionneig(1,2:4)];
        tabulist = [tabulist(2:tabulength,1:7); TabuAdd];
        if currentcost < bestcostneig
            omega_des1(1,des_option) = omega_des1(1,des_option) + alpha3;
            omega_rep1(1,rep_option) = omega_rep1(1,rep_option) + alpha3;
        else
            omega_des1(1,des_option) = omega_des1(1,des_option) + alpha2;
            omega_rep1(1,rep_option) = omega_rep1(1,rep_option) + alpha2;
        end
        currentcost = bestcostneig;
        if bestcostneig < bestcost %%%%% If the best neighborhood solution is better than the historical best solution
            bestcost = currentcost;
            bestsolution = currentsolution;
            omega_des1(1,des_option) = omega_des1(1,des_option) + alpha1;
            omega_rep1(1,rep_option) = omega_rep1(1,rep_option) + alpha1;
        end
    end
    CurrentNoTsSolutionCell{i,1} = CurrentNoTsSolution;
    His_best(i,1) = bestcost;
    His_TsRelationship{i,1} = TsRelationship;
    His_solution{i,1} = currentsolution;
    His_no_ts_solution{i,1} = CurrentNoTsSolution;
    if i/lambda - ceil(i/lambda) == 0
        omega_des = omega_des1;
        omega_rep = omega_rep1;
    end
end
% objecrtive_change_tabulength(mm,1)=bestcost;
% end
% Plotting
% hand2 = plot(1:maxiteration, best(:,1));
% set(hand2, 'color', 'r', 'linestyle', '-', 'linewidth', 0.5, 'markersize', 6)
% xlabel('iteration'); ylabel('cost'); xlim([1 maxiteration]);
% % legend('currentcost', 'bestcost');
% legend('bestcost');
% hold off
% box off;
%% ============== Plotting ==============
% % figure(1)   % Plot the shortest route
% % for j = 1:vhcnum
% %     Shortest_Route = bestsolution{j,1};
% %     Shortest_Route = [Shortest_Route Shortest_Route(1)];
% %     plot([allLocation(Shortest_Route,1)], [allLocation(Shortest_Route,2)], 'o-');
% %     hold on
% % end
% % grid on
% % for i = 1:size(allLocation,1)
% %     text(allLocation(i,1), allLocation(i,2), ['   ' num2str(i)]);
% % end
% % xlabel('City X coordinate'); ylabel('City Y coordinate'); 
bestsolution
toc
for i = 1:vhcnum
    if i == 1
        dlmwrite('test.csv', bestsolution{i,1}, 'delimiter', ',');
    else
        dlmwrite('test.csv', bestsolution{i,1}, 'delimiter', ',', '-append');
    end
end
