function [YON,solution] = InsertdeliverypointALNS0711(AwithFF,TS_point,TsAfterThis,BTsToA,ATsToB,demand,DemandF,epos,index,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,vhccapacity,fixedcost,cwk,ctk,TravelTimeMax,op,tsop)
% Insert a transfer, remove every outgoing delivery, then insert incoming ones.
% This tests one vehicle; a coupled transfer schedule is checked separately.
YON = 0;
solution = [];
route = [AwithFF(1:TsAfterThis),TS_point,AwithFF(TsAfterThis+1:end)];
route = route(~ismember(route,ATsToB+demand));
for request = BTsToA
    transferPosition = find(route == TS_point,1);
    base = route;
    found = false;
    for after = transferPosition:numel(base)
        candidate = [base(1:after),request+demand,base(after+1:end)];
        if judgement_op(candidate,index,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,demand,op,tsop) && ...
                CalculatingTotalTime(index,candidate,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk,TravelTimeMax)
            route = candidate;
            found = true;
            break
        end
    end
    if ~found, return; end
end
if judgement_op(route,index,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,demand,op,tsop) && ...
        CalculatingTotalTime(index,route,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk,TravelTimeMax) && ...
        CapacityCheck(index,route,demand,vhccapacity)
    YON = 1;
    solution = route;
end
end
