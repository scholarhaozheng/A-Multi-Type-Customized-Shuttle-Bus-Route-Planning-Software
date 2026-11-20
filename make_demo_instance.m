function data = make_demo_instance()
%MAKE_DEMO_INSTANCE Six synthetic requests, three vehicle types and two depots.
% Coordinates are kilometres; travel and service times are minutes.
data.demand = 6;
data.vhcnum = 3;
data.tsNum = 2;
data.depotNum = 2;
data.demandstartlocation = [1 1; 2 1; 7 1; 8 1; 4 7; 5 7];
data.demandendlocation = [2 3; 3 3; 8 3; 9 3; 5 9; 6 9];
data.tsLocation = [4.5 4; 6 4];
data.depLocation = [0 0; 10 0];
data.demandlocation = [data.demandstartlocation; data.demandendlocation];
data.allLocation = [data.demandlocation; data.tsLocation; data.depLocation];
n = size(data.allLocation,1);
data.distancematrix = zeros(n);
for i = 1:n
    for j = 1:n
        data.distancematrix(i,j) = sqrt(sum((data.allLocation(i,:) - data.allLocation(j,:)).^2));
    end
end
data.timematrix = 2 * data.distancematrix; % 30 km/h.
data.TS = [13 14];
data.vhcdepot = [15; 16; 15];
data.vhclocation = data.allLocation(data.vhcdepot,:);
data.vhcdemandtimematrix = data.timematrix(data.vhcdepot,:);
data.vhctype = [1; 2; 3];
data.vhccapacity = [2; 3; 4];
data.fixedcost = [40; 60; 80];
data.cwk = [2; 3; 4];
data.ctk = [1.5; 2; 2.5];
data.demandstarttime = repmat([10 60],data.demand,1);
data.demandendtime = repmat([20 100],data.demand,1);
data.demandtime = [data.demandstarttime; data.demandendtime];
data.vhcstarttime = repmat([0 0],data.vhcnum,1);
data.vhcendtime = repmat([0 180],data.vhcnum,1);
data.depotendtime = [15 180; 16 180];
data.op = 2;
data.tsop = 3;
data.TravelTimeMax = 180;
data.inisolution1 = {[1 2 7 8]; [3 4 9 10]; [5 6 11 12]};
data.inireject1 = zeros(0,1);
data.maxiteration = 5;
data.neignum = 3;
data.tabulength = 8;
data.lambda = 10;
data.alpha1 = 1;
data.alpha2 = 0.8;
data.alpha3 = 0.6;
data.SetTsMax = 4;
data.EachOptionMax = 4;
[data.inicost1,~] = calculatetotalcost_test(data.inisolution1,data.demand, ...
    data.vhccapacity,data.demandstarttime,data.demandendtime,data.vhcstarttime, ...
    data.timematrix,data.vhcdemandtimematrix,data.fixedcost,data.cwk,data.ctk, ...
    data.op,data.tsop);
end
