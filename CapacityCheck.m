function [ YN ] = CapacityCheck(index,vehicle_chain,demand,vhccapacity)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if size(vehicle_chain,2)==0
    YN=1;
else
    YN=1;
    TsPoints=vehicle_chain(vehicle_chain>2*demand);
    CapacityChain=zeros(1,size(vehicle_chain,2));
    if isempty(TsPoints)
        for i=1:size(vehicle_chain,2)
            if i==1
                CapacityChain(1,1)=1;
            else
                if vehicle_chain(1,i)<=demand
                    CapacityChain(1,i)=CapacityChain(1,i-1)+1;
                else
                    CapacityChain(1,i)=CapacityChain(1,i-1)-1;
                end
            end
        end
    else
        if size(TsPoints,1)>1
            vehicle_chain
            TsPoints
            save debug.0426TS
            display('Ts wrong')
        end
        [~,position]=find(vehicle_chain==TsPoints(1));
        for i=1:position-1
            if i==1
                CapacityChain(1,1)=1;
            else
                if vehicle_chain(1,i)<=demand
                    CapacityChain(1,i)=CapacityChain(1,i-1)+1;
                else
                    CapacityChain(1,i)=CapacityChain(1,i-1)-1;
                end
            end
        end
        Pickups=vehicle_chain(vehicle_chain<=demand);
        Deliverys=vehicle_chain(vehicle_chain>demand);
        PickUpAndDelivery=intersect(Pickups,Deliverys);
        OnlyPickUp=setdiff(Pickups,PickUpAndDelivery);
        OnlyDeliver=setdiff(Deliverys,PickUpAndDelivery);
        CapacityChain(1,position)=CapacityChain(1,position-1)+size(OnlyDeliver,2)-size(OnlyPickUp,2);
        for i=position+1:size(vehicle_chain,2)
            if vehicle_chain(1,i)<=demand
                CapacityChain(1,i)=CapacityChain(1,i-1)+1;
            else
                CapacityChain(1,i)=CapacityChain(1,i-1)-1;
            end
        end
    end
    for i=1:size(vehicle_chain,2)
        if CapacityChain(i)>vhccapacity(index,1)
            YN=0;
            break
        end
    end
end