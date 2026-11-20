function [Distance,objective] = GeneratingTravelingDistance(solutioncell,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk,vhcindex)
cost=0;
objective=[];
for i=1:size(solutioncell,1)
    thiscost=0;
    CostLast=cost;
    chain_proceeding=solutioncell{i};
    if size(chain_proceeding,2)==0
        objective=[objective,0];
        continue
    end
    
    ChainLength=size(chain_proceeding,2);
    for j=1:ChainLength
        if j==1
            cost=cost+vhcdemandtimematrix(1,chain_proceeding(1,1));
            thiscost=thiscost+vhcdemandtimematrix(i,chain_proceeding(1,1));
        elseif j<=ChainLength-1
            cost=cost+timematrix(j,j+1);
            thiscost=thiscost+timematrix(j,j+1);
        else
            thiscost=thiscost+vhcdemandtimematrix(1,chain_proceeding(1,1));
        end
    end
    %%%%%%cost=cost+timematrix(chain_proceeding(1,ChainLength);回到depot的时间
    objective=[objective,thiscost];
end
Cost=cost;
Distance=Cost/2;
objective=objective/2;

