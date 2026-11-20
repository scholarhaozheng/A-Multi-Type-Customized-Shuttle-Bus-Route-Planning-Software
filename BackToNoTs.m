function [YN,solutionaReinsertOut] = BackToNoTs(index,currentsolutioncell,CurrentNoTsSolutionCell,TsRelationship,demand,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,TS,depotendtime,vhccapacity,fixedcost,cwk,ctk,vhcdepot,des_option,rep_option,TravelTimeMax,op,tsop,SetTsMax,EachOptionMax,iteration,solutionaReinsert)
% Reinsert deliveries for the vehicle's pickups, considering at most 8 orders.
YN = 0;
solutionaReinsertOut = [];
requests = solutionaReinsert(:)';
if isempty(requests)
    YN = 1;
    return
end
if numel(requests) <= 3
    orders = perms(requests);
else
    orders = requests;
    for attempt = 1:64
        candidate = requests(randperm(numel(requests)));
        if ~ismember(candidate,orders,'rows')
            orders = [orders;candidate];
        end
        if size(orders,1) == 8, break; end
    end
end
for row = 1:size(orders,1)
    route = requests;
    successful = true;
    for request = orders(row,:)
        base = route;
        pickupPosition = find(base == request,1);
        found = false;
        for after = pickupPosition:numel(base)
            candidate = [base(1:after),request+demand,base(after+1:end)];
            if judgement_op(candidate,index,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,demand,op,tsop) && ...
                    CalculatingTotalTime(index,candidate,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk,TravelTimeMax)
                route = candidate;
                found = true;
                break
            end
        end
        if ~found
            successful = false;
            break
        end
    end
    if successful && CapacityCheck(index,route,demand,vhccapacity)
        YN = 1;
        solutionaReinsertOut = route;
        return
    end
end
end
