function [CapacityChain,valid] = CapacityPunishment(index,vehicle_chain,demand,vhccapacity)
% Unit-passenger loads after each node; at most one transfer per route.
% Missing pickup/delivery counterparts identify transfers between vehicles.
route = vehicle_chain(:)';
CapacityChain = zeros(size(route));
valid = true;
if isempty(route)
    return
end
if any(~isfinite(route)) || any(route < 1) || any(route ~= fix(route)) || ...
        numel(unique(route)) ~= numel(route)
    valid = false;
    return
end
transfer = find(route > 2*demand);
pickups = route(route <= demand);
deliveries = route(route > demand & route <= 2*demand) - demand;
outgoing = setdiff(pickups,deliveries);
incoming = setdiff(deliveries,pickups);
if numel(transfer) > 1 || (isempty(transfer) && ...
        (~isempty(outgoing) || ~isempty(incoming)))
    valid = false;
end
for request = intersect(pickups,deliveries)
    if find(route == request,1) >= find(route == request+demand,1)
        valid = false;
    end
end
if numel(transfer) == 1
    for request = outgoing
        if find(route == request,1) >= transfer
            valid = false;
        end
    end
    for request = incoming
        if find(route == request+demand,1) <= transfer
            valid = false;
        end
    end
end
load = 0;
for j = 1:numel(route)
    if route(j) <= demand
        load = load + 1;
    elseif route(j) <= 2*demand
        load = load - 1;
    elseif numel(transfer) == 1
        load = load + numel(incoming) - numel(outgoing);
    end
    CapacityChain(j) = load;
end
valid = valid && all(CapacityChain >= 0) && CapacityChain(end) == 0;
end
