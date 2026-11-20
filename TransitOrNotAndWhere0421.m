function [SetTs] = TransitOrNotAndWhere0421(AwithoutEwithF,BwithoutFwithE,vhcdepot,a,b,demand,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,TS,depotendtime,vhccapacity,fixedcost,cwk,ctk,op,tsop)

depotA=vhcdepot(a,1);
depotB=vhcdepot(b,1);
DemandTW=[demandstarttime;demandendtime];
DmadStT=DemandTW(:,1);
DmadEdT=DemandTW(:,2);
% Candidate intervals describe an overlapping transfer service interval.
numTS=size(TS,2);
TS_solution_1=[];
TS_solution_2=[];
LengthA=size(AwithoutEwithF,2);
LengthB=size(BwithoutFwithE,2);
EARATA=zeros(1,LengthA);%%%%Earliest_Arriving_Time_A
EARATB=zeros(1,LengthB);
LAARTA=zeros(1,LengthA);%%%%Latest_Arriving_Time_A
LAARTB=zeros(1,LengthB);%%%%Latest_Arriving_Time_B
for i=1:LengthA
    processing_node=AwithoutEwithF(1,i);
    if i==1
        EARATA(1,i)=max(vhcstarttime(a,1)+vhcdemandtimematrix(a,processing_node),DmadStT(processing_node,1));
    else
        Arrival_time1= EARATA(1,i-1)+op+timematrix(AwithoutEwithF(i-1),AwithoutEwithF(i));
        if processing_node>demand*2
            Arrival_time2=0;
        else
            Arrival_time2= DmadStT(processing_node,1);
        end
        EARATA(1,i)=max(Arrival_time1,Arrival_time2);
    end
end
for i=1:LengthA
    if i==1
        [depot_num,~]=find(depotendtime(:,1)==depotA);
        ReachTime1=min(depotendtime(depot_num,2),vhcendtime(a,2))-vhcdemandtimematrix(a,AwithoutEwithF(LengthA))-op;
        ReachTime2=DmadEdT(AwithoutEwithF(LengthA),1);
        LAARTA(LengthA-i+1)=min(ReachTime1,ReachTime2);
    else
        TravelTime_I_IPlusOne=timematrix(AwithoutEwithF(LengthA-i+1),AwithoutEwithF(LengthA-i+2));
        LAARTA1=LAARTA(LengthA-i+2)-TravelTime_I_IPlusOne-op;
        if AwithoutEwithF(LengthA-i+1)>demand*2
            LAARTA2=9999999;
        else
            LAARTA2=DmadEdT(AwithoutEwithF(LengthA-i+1),1);
        end
        LAARTA(LengthA-i+1)=min(LAARTA1,LAARTA2);
    end
end
for i=1:LengthB
    processing_node=BwithoutFwithE(1,i);
    if i==1
        EARATB(1,i)=max(vhcstarttime(b,1)+vhcdemandtimematrix(b,processing_node),DmadStT(processing_node,1));
    else
        Arrival_time1= EARATB(1,i-1)+op+timematrix(BwithoutFwithE(i-1),BwithoutFwithE(i));
        if processing_node>demand*2
            Arrival_time2=0;
        else
            Arrival_time2= DmadStT(processing_node,1);
        end
        EARATB(1,i)=max(Arrival_time1,Arrival_time2);
    end
end
for i=1:LengthB
    if i==1
        [depot_num,~]=find(depotendtime(:,1)==depotB);
        ReachTime1=min(depotendtime(depot_num,2),vhcendtime(b,2))-vhcdemandtimematrix(b,BwithoutFwithE(LengthB))-op;
        ReachTime2=DmadEdT(BwithoutFwithE(LengthB),1);
        LAARTB(LengthB-i+1)=min(ReachTime1,ReachTime2);
    else
        TravelTime_I_IPlusOne=timematrix(BwithoutFwithE(LengthB-i+1),BwithoutFwithE(LengthB-i+2));
        LAARTB1=LAARTB(LengthB-i+2)-TravelTime_I_IPlusOne-op;
        if BwithoutFwithE(LengthB-i+1)>demand*2
            LAARTB2=9999999;
        else
            LAARTB2=DmadEdT(BwithoutFwithE(LengthB-i+1),1);
        end
        LAARTB(LengthB-i+1)=min(LAARTB1,LAARTB2);
    end
end

A_TS=[];
B_TS=[];
for i=1:(LengthA-1)
    for t=1:numTS
        TsArriveEarliest=EARATA(i)+op+timematrix(AwithoutEwithF(i),TS(t));
        TsLeaveLatest=LAARTA(i+1)-timematrix(TS(t),AwithoutEwithF(i+1));
        if TsLeaveLatest-TsArriveEarliest>=tsop
            A_TS_add=[i,t,TsArriveEarliest,TsLeaveLatest];
            A_TS=[A_TS;A_TS_add];
        end
    end
end
for i=1:(LengthB-1)
    for t=1:numTS
        TsArriveEarliest=EARATB(i)+op+timematrix(BwithoutFwithE(i),TS(t));
        TsLeaveLatest=LAARTB(i+1)-timematrix(TS(t),BwithoutFwithE(i+1));
        if TsLeaveLatest-TsArriveEarliest>=tsop
            B_TS_add=[i,t,TsArriveEarliest,TsLeaveLatest];
            B_TS=[B_TS;B_TS_add];
        end
    end
end
ATS_num=size(A_TS,1);
BTS_num=size(B_TS,1);
SetTs=[];
for i=1:ATS_num
    for j=1:BTS_num
        if A_TS(i,2)~=B_TS(j,2)

        else
            LatestArrive=min(A_TS(i,4),B_TS(j,4));
            EarliestArrive=max(A_TS(i,3),B_TS(j,3));
            T_coincide=LatestArrive-EarliestArrive;
            if T_coincide>=tsop
                t=B_TS(j,2);
                a_node=A_TS(i,1);
                b_node=B_TS(j,1);
                SetTs=[SetTs;a_node,b_node,AwithoutEwithF(1,a_node),BwithoutFwithE(1,b_node),TS(1,t),EarliestArrive,LatestArrive];
            else

            end
        end
    end
end









