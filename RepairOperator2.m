function [ YNAall,AwithFF,InsertPositionA ] = RepairOperator2_0505( AwithoutEE,DeteleNumB,DemandFList,a,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,demand,NoTsSolutioncell,vhccapacity,fixedcost,cwk,ctk,TravelTimeMax,op,tsop,UnservedDemand )
AwithFF=[];
InsertPositionA=[];
NoTsSolutioncellUse=NoTsSolutioncell;
A_middle=AwithoutEE;
SZAM=size(A_middle,2);
YNAall=0;
YNA=0;
for m=1:DeteleNumB
    DemandF=DemandFList(1,m);
    if size(A_middle,2)==0
        AwithoutEEwithF=[DemandF];
        InsertPositionA=1;
        YNA1=1;
        Apart1=AwithoutEEwithF;
        Apart2=[];
        AwithFF=[Apart1,DemandF+demand,Apart2];
        YNA2 = judgement_op(AwithFF,a,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,demand,op,tsop);
        [ YNtime2 ] = CalculatingTotalTime(a,AwithFF,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk,TravelTimeMax);
        if YNA1&&YNA2&&YNtime2
            YNA=1;
            A_middle=AwithFF;
        else
            YNA=0;
            break
        end
    else
        j=1;
        solution_listA=cell(1,size(A_middle,2)+1);
        cost_listA=9999999999*ones(1,size(A_middle,2)+1);
        while j<=size(A_middle,2)+1
            NoTsSolutioncellUse=NoTsSolutioncell;
            YNA=0;
            InsertPositionA=j;
            if InsertPositionA==1
                AwithoutEEwithF=[DemandF,A_middle];
            elseif InsertPositionA<=size(A_middle,2)
                AwithoutEEwithF=[A_middle(1,1:InsertPositionA-1),DemandF,A_middle(1,InsertPositionA:end)];
            elseif InsertPositionA==size(A_middle,2)+1
                AwithoutEEwithF=[A_middle(1,1:end),DemandF];
            end
            YNA1 = judgement_op(AwithoutEEwithF,a,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,demand,op,tsop);
            [ YNtime1 ] = CalculatingTotalTime(a,AwithFF,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk,TravelTimeMax);
            if YNA1==0||YNtime1==0
                if YNtime1==0
                    display('YNtime1==0')
                end
                j=j+1;
                continue
            end
            for i=InsertPositionA:(size(A_middle,2)+2)
                if i<(size(A_middle,2)+2)
                    Apart1=AwithoutEEwithF(1,1:i);
                    Apart2=AwithoutEEwithF(1,i+1:end);
                else
                    Apart1=AwithoutEEwithF(1,1:end);
                    Apart2=[];
                end
                AwithFF=[Apart1,DemandF+demand,Apart2];
                YNA2 = judgement_op(AwithFF,a,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,demand,op,tsop);
                [ YNtime2 ] = CalculatingTotalTime(a,AwithFF,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk,TravelTimeMax);
                [ YNcapacity ] = CapacityCheck(a,AwithFF,demand,vhccapacity);
                if YNA2==1&&YNtime2==1&&YNcapacity==1
                    break
                end
            end
            if YNA1&&YNA2&&YNtime2&&YNcapacity
                YNA=1;
                NoTsSolutioncellUse{a,1}=AwithFF;
                [cost_listA(1,j),~]=calculatetotalcost_test(NoTsSolutioncellUse,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk);
                solution_listA{1,j}=AwithFF;
                j=j+1;
            else
                YNA=0;
                j=j+1;
                continue
            end
        end
        [mincostA,InsertPositionA]=min(cost_listA);
        if mincostA==9999999999
            YNA=0;
            YNAall=0;
            break
        else
            YNA=1;
            A_middle=solution_listA{1,InsertPositionA};
        end
    end
    if YNA==0
        YNAall=0;
        break
    else
        YNAall=1;
    end
end

if YNAall==1
    AwithFF=A_middle;
    InsertPositionA=zeros(1,size(DemandFList,2));
    for i=1:size(DemandFList,2)
        InsertPositionA(i)=find(AwithFF==DemandFList(i));
    end
    %display('Completed!!!')
    for i=1:size(DemandFList,2)
        if isempty(find(AwithFF==DemandFList(i)))
            AwithFF
            DemandFList
            display('Wrong!')
            pause(10000000)
        end
    end
end

end

