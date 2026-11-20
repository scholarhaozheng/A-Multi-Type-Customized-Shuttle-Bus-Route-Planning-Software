function [ YNAall,AwithFF,InsertPositionA ] = RepairOperator2_0426( AwithoutEE,DeteleNumB,DemandFList,a,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,demand,NoTsSolutioncell,vhccapacity,fixedcost,cwk,ctk,TravelTimeMax,op,tsop )
% Cheapest pickup position among first-feasible delivery insertions.
% This is a greedy repair; no regret-2 operator is implemented here.
A_middle = AwithoutEE;
YNAall = 1;
AwithFF = A_middle;
InsertPositionA = [];
for m = 1:DeteleNumB
    request = DemandFList(m);
    n = numel(A_middle);
    bestCost = inf;
    bestRoute = [];
    for pickup = 1:n+1
        partial = [A_middle(1:pickup-1),request,A_middle(pickup:end)];
        for delivery = pickup+1:n+2
            candidate = [partial(1:delivery-1),request+demand,partial(delivery:end)];
            feasible = judgement_op(candidate,a,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,demand,op,tsop) && ...
                CalculatingTotalTime(a,candidate,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk,TravelTimeMax) && ...
                CapacityCheck(a,candidate,demand,vhccapacity);
            if feasible
                scored = NoTsSolutioncell;
                scored{a,1} = candidate;
                cost = calculatetotalcost_test(scored,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk,op,tsop);
                if cost < bestCost
                    bestCost = cost;
                    bestRoute = candidate;
                end
                break
            end
        end
    end
    if isempty(bestRoute)
        YNAall = 0;
        AwithFF = [];
        return
    end
    A_middle = bestRoute;
end
AwithFF = A_middle;
InsertPositionA = zeros(1,DeteleNumB);
for m = 1:DeteleNumB
    InsertPositionA(m) = find(AwithFF == DemandFList(m),1);
end
end
