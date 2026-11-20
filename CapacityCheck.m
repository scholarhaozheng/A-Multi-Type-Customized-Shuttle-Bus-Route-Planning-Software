function YN = CapacityCheck(index,vehicle_chain,demand,vhccapacity)
% Check request ordering, transfer load balance, and vehicle capacity.
[loads,valid] = CapacityPunishment(index,vehicle_chain,demand,vhccapacity);
YN = valid && all(loads <= vhccapacity(index));
end
