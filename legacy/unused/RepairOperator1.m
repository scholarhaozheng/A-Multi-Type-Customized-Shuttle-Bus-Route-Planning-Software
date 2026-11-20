function [ YNA,AwithFF,InsertPositionA ] = RepairOperator1_0410( AwithoutEE,DeteleNumB,DemandFList,a,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,demand,NoTsSolutioncell,vhccapacity,fixedcost,cwk,ctk,TravelTimeMax,op,tsop );
AwithFF=[];
InsertPositionA=[];
A_middle=AwithoutEE;
SZAxE=size(A_middle,2);
countA1=0;
YNA=0;
for m=1:DeteleNumB
    DemandF=DemandFList(1,m);
    YNA=0;
    if SZAxE==0
        InsertPositionA=0;
    else
        InsertPositionA=randi(SZAxE);
    end
    while YNA==0&&countA1<=SZAxE
        countA1=countA1+1;
        if InsertPositionA+1<SZAxE
            InsertPositionA=InsertPositionA+1;
        else
            InsertPositionA=1;
        end
        if InsertPositionA==1
            AwithoutEEwithF=[DemandF,A_middle];
        else
            AwithoutEEwithF=[A_middle(1,1:InsertPositionA),DemandF,A_middle(1,InsertPositionA+1:end)];
        end
        YNA1=0;
        YNA1 = judgement_op(AwithoutEEwithF,a,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,demand,op,tsop);
        [ YNtime1 ] = CalculatingTotalTime(a,AwithoutEEwithF,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk,TravelTimeMax);
        if YNA1==0||YNtime1==0
            continue
        end
        YNA2=0;
        if SZAxE==0
            InsertPositionA=0;
        end
        for i=InsertPositionA+1:(SZAxE+1)
            Apart1=AwithoutEEwithF(1,1:i);
            Apart2=AwithoutEEwithF(1,i+1:end);
            AwithFF=[Apart1,DemandF+demand,Apart2];
            YNA2 = judgement_op(AwithFF,a,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,demand,op,tsop);
            [ YNtime2 ] = CalculatingTotalTime(a,AwithFF,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk,TravelTimeMax);
            [ YNcapacity ] = CapacityCheck(a,AwithFF,demand,vhccapacity);
            if YNA2==1&&YNtime2==1&&YNcapacity==1
                break
            end
        end
        if YNA1&&YNA2&&YNtime2==1&&YNcapacity==1
            YNA=1;
            A_middle=AwithFF;
            break
        else
            YNA=0;
        end
    end
end
if YNA==1
    InsertPositionA=zeros(1,size(DemandFList,2));
    for i=1:size(DemandFList,2)
        InsertPositionA(i)=find(AwithFF==DemandFList(i));
    end
end
end

