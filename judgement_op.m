function YN = judgement_op(solution,vhcindex,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,demand,op,tsop)
% Individual-route time windows, service durations, and depot return.
YN = RouteSchedule(solution,vhcindex,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,demand,op,tsop);
end
