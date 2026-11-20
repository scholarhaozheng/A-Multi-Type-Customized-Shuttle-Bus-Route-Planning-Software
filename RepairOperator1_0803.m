function [ YNA,AwithFF,InsertPositionA ] = RepairOperator1_0803( AwithoutEE,DeteleNumB,DemandFList,a,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,demand,NoTsSolutioncell,vhccapacity,fixedcost,cwk,ctk,TravelTimeMax,op,tsop )
% Random starting pickup position, followed by first feasible paired insertion.
A_middle = AwithoutEE;
YNA = 1;
AwithFF = A_middle;
InsertPositionA = [];
for m = 1:DeteleNumB
    request = DemandFList(m);
    n = numel(A_middle);
    first = randi(n+1);
    positions = [first:n+1,1:first-1];
    found = false;
    for pickup = positions
        partial = [A_middle(1:pickup-1),request,A_middle(pickup:end)];
        for delivery = pickup+1:n+2
            candidate = [partial(1:delivery-1),request+demand,partial(delivery:end)];
            if judgement_op(candidate,a,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,demand,op,tsop) && ...
                    CalculatingTotalTime(a,candidate,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk,TravelTimeMax) && ...
                    CapacityCheck(a,candidate,demand,vhccapacity)
                A_middle = candidate;
                found = true;
                break
            end
        end
        if found, break; end
    end
    if ~found
        YNA = 0;
        AwithFF = [];
        return
    end
end
AwithFF = A_middle;
InsertPositionA = zeros(1,DeteleNumB);
for m = 1:DeteleNumB
    InsertPositionA(m) = find(AwithFF == DemandFList(m),1);
end
end
