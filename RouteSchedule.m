function [YN,arrival,departure,waiting,returnTime] = RouteSchedule(route,vehicle,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,demand,op,tsop)
% Earliest individual-vehicle schedule with service-start time windows.
% Transfer waiting for another vehicle is not represented by this helper.
% Depot legs use the supplied depot-time row in both directions.
route = route(:)';
n = numel(route);
arrival = zeros(1,n);
departure = zeros(1,n);
waiting = zeros(1,n);
returnTime = vhcstarttime(vehicle,1);
YN = true;
if isempty(route)
    return
end
if any(~isfinite(route)) || any(route < 1) || any(route ~= fix(route)) || ...
        any(route > size(timematrix,1)) || ...
        any(route > size(vhcdemandtimematrix,2)) || ...
        numel(unique(route)) ~= n
    YN = false;
    return
end
windows = [demandstarttime; demandendtime];
for j = 1:n
    node = route(j);
    if j == 1
        reach = vhcstarttime(vehicle,1) + vhcdemandtimematrix(vehicle,node);
    else
        reach = departure(j-1) + timematrix(route(j-1),node);
    end
    if node <= 2*demand
        arrival(j) = max(reach,windows(node,1));
        waiting(j) = arrival(j) - reach;
        departure(j) = arrival(j) + op;
        if arrival(j) > windows(node,2)
            YN = false;
        end
    else
        arrival(j) = reach;
        departure(j) = reach + tsop;
    end
end
returnTime = departure(end) + vhcdemandtimematrix(vehicle,route(end));
YN = YN && returnTime <= vhcendtime(vehicle,2);
% Partial insertion routes may omit a counterpart; existing pairs must be ordered.
for request = route(route <= demand)
    deliveryPosition = find(route == request+demand,1);
    if ~isempty(deliveryPosition) && deliveryPosition < find(route == request,1)
        YN = false;
    end
end
end
