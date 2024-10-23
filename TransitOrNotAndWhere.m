function [SetTs] = TransitOrNotAndWhere0421(AwithoutEwithF,BwithoutFwithE,vhcdepot,a,b,demand,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,TS,depotendtime,vhccapacity,fixedcost,cwk,ctk,op,tsop)
%TS点插入条件与最佳插入点判定
%%输入：solution中不包括起始depot点和depot终止点，包括将要交换的点，不包括将要交换的点对应的下车点，但是包括其它下车点
%%中间的运算过程：不去掉demand点进行运算
%%输出：solution中包括所有demand点

depotA=vhcdepot(a,1);
depotB=vhcdepot(b,1);
%solutiona=solutiona(solutiona<=demand);
%solutionb=solutionb(solutionb<=demand);
DemandTW=[demandstarttime;demandendtime];
DmadStT=DemandTW(:,1);
DmadEdT=DemandTW(:,2);
pwt=1;%%%passenger waiting time
numTS=size(TS,2);
TS_solution_1=[];%%两条车辆链，插入位置，哪个TS点,TS点到达上限时间，TS点到达下限时间,先到哪个点
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
        %%EARATA(1,i)=max(vhcstarttime(a,1)+timematrix(depotA,processing_node),DmadStT(processing_node,1));
        EARATA(1,i)=max(vhcstarttime(a,1)+vhcdemandtimematrix(a,processing_node),DmadStT(processing_node,1));
    else
        Arrival_time1= EARATA(1,i-1)+timematrix(AwithoutEwithF(i-1),AwithoutEwithF(i));
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
        [depot_num,~]=find(depotendtime==depotA);
        ReachTime1=depotendtime(depot_num,2)-vhcdemandtimematrix(a,AwithoutEwithF(LengthA));
        ReachTime2=DmadEdT(AwithoutEwithF(LengthA),1);
        LAARTA(LengthA-i+1)=min(ReachTime1,ReachTime2);
        %%%%%最晚到达某个depot的时间
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
        %%EARATB(1,i)=max(vhcstarttime(b,1)+timematrix(depotB,processing_node),DmadStT(processing_node,1));
        EARATB(1,i)=max(vhcstarttime(b,1)+vhcdemandtimematrix(b,processing_node),DmadStT(processing_node,1));
    else
        Arrival_time1= EARATB(1,i-1)+timematrix(BwithoutFwithE(i-1),BwithoutFwithE(i));
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
        [depot_num,~]=find(depotendtime==depotB);
        ReachTime1=depotendtime(depot_num,2)-vhcdemandtimematrix(b,BwithoutFwithE(LengthB));
        ReachTime2=DmadEdT(BwithoutFwithE(LengthB),1);
        LAARTB(LengthB-i+1)=min(ReachTime1,ReachTime2);
        %%%%%最晚到达某个depot的时间
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
    %%%%有哪些点可以插入TS点
    for t=1:numTS
        TsArriveEarliest=EARATA(i)+timematrix(TS(t),AwithoutEwithF(i));
        TsLeaveLatest=LAARTA(i+1)-timematrix(TS(t),AwithoutEwithF(i));
        if TsLeaveLatest-TsArriveEarliest>=tsop
            A_TS_add=[i,t,TsArriveEarliest,TsLeaveLatest];
            A_TS=[A_TS;A_TS_add];
        end
    end
end
for i=1:(LengthB-1)
    for t=1:numTS
        TsArriveEarliest=EARATB(i)+timematrix(TS(t),BwithoutFwithE(i));
        TsLeaveLatest=LAARTB(i+1)-timematrix(TS(t),BwithoutFwithE(i));
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
            T_coincide=LatestArrive+pwt-EarliestArrive;
            if T_coincide>=op
                t=B_TS(j,2);
                a_node=A_TS(i,1);
                b_node=B_TS(j,1);
                SetTs=[SetTs;a_node,b_node,AwithoutEwithF(1,a_node),BwithoutFwithE(1,b_node),TS(1,t),EarliestArrive,LatestArrive];
            else
                
            end
        end
    end
end









