function [ YN ] = CalculatingTotalTime(index,vehicle_chain,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk,TravelTimeMax)
if size(vehicle_chain,2)==0
    YN=1;
else
    TravelTime=vhcdemandtimematrix(index,vehicle_chain(1,1));
    for j=1:size(vehicle_chain,2)-1
        TravelTime=TravelTime+timematrix(vehicle_chain(1,j),vehicle_chain(1,j+1));
    end
    if TravelTime>TravelTimeMax
        YN=0;
    else
        YN=1;
    end
end
end

