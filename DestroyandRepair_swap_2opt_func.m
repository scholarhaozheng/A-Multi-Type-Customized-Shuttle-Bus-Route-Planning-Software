function [TsRelationNewWithTS,TsRelationshipNoTs,tablesolutionneig, NoTsSolutioncell, BestAllSolutionTs,BestAllOverCostTs] = DestroyandRepair_swap_2opt_func0803_edit_rep_1(currentsolutioncell,CurrentNoTsSolutionCell,TsRelationship,demand,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,TS,depotendtime,vhccapacity,fixedcost,cwk,ctk,vhcdepot,des_option,rep_option,TravelTimeMax,op,tsop,SetTsMax,EachOptionMax,iteration,His_TsRelationship)
%%%function [TsRelationNewWithTS,TsRelationshipNoTs,tablesolutionneig, NoTsSolutioncell, BestAllSolutionTs,BestAllOverCostTs] = performswapTS_zh_Im(currentsolutioncell,CurrentNoTsSolution,TsRelationship,demand,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,TS,depotendtime,vhccapacity,fixedcost,cwk,ctk,vhcdepot,des_option,rep_option)
%%%%%输出的nsolutioncell和BestAllSolutionTs均带下车点和TS点
M = size(currentsolutioncell,1);
demandtime=[demandstarttime;demandendtime];
YN = 0;
r=0.1;
% % TsRelationship=[
% %     iteration,jthneighbor,a];
%%%%%在加入需要的约束之前的权宜之计
if rep_option==3
    rep_option=2;
end
while YN == 0
    f=0;
    YNback=0;
    while YNback==0
        a = randi(M);
        b = randi(M);
        NoTsSolutioncell=currentsolutioncell;
        solutionOria = currentsolutioncell{a,1};%%%%%%车辆链A
        solutionOrib = currentsolutioncell{b,1};%%%%%%车辆链B
        rt = (isempty(solutionOria))||(isempty(solutionOrib));
        while (a == b)||(rt == 1)       %保证非空且不等
            a = randi(M);
            b = randi(M);
            solutionOria = currentsolutioncell{a,1};
            solutionOrib = currentsolutioncell{b,1};
            rt = (isempty(solutionOria))||(isempty(solutionOrib));
        end
        display([ num2str(a) ' and ' num2str(b) ' are chosen' ])
        TsRelationshipNoTs=TsRelationship;
        solutionNoTsa=solutionOria;
        solutionNoTsb=solutionOrib;
        YNa=1;
        YNaa=1;
        YNb=1;
        YNbb=1;
        if TsRelationship(a,1)~=0%%%两列车辆数行
            PointTsWithA=TsRelationship(a,1);
            display([ num2str(a) ' and ' num2str(PointTsWithA) ' are related' ]);
            solutionaReinsert=solutionOria;
            solutionReinsertPointWitha=currentsolutioncell{PointTsWithA,1};
            solutionaReinsert=solutionaReinsert(solutionaReinsert<=demand);
            solutionReinsertPointWitha=solutionReinsertPointWitha(solutionReinsertPointWitha<=demand);
            [YNa,solutionaReinsertOut] = BackToNoTs(a,currentsolutioncell,CurrentNoTsSolutionCell,TsRelationship,demand,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,TS,depotendtime,vhccapacity,fixedcost,cwk,ctk,vhcdepot,des_option,rep_option,TravelTimeMax,op,tsop,SetTsMax,EachOptionMax,iteration,solutionaReinsert);
            [YNaa,solutionReinsertPointWithaOut] = BackToNoTs(PointTsWithA,currentsolutioncell,CurrentNoTsSolutionCell,TsRelationship,demand,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,TS,depotendtime,vhccapacity,fixedcost,cwk,ctk,vhcdepot,des_option,rep_option,TravelTimeMax,op,tsop,SetTsMax,EachOptionMax,iteration,solutionReinsertPointWitha);
            display([ num2str(a) ':  ' num2str(YNa) ',' num2str(PointTsWithA) ':  ' num2str(YNaa) ]);
            NoTsSolutioncell{a,1}=solutionaReinsertOut;
            NoTsSolutioncell{PointTsWithA,1}=solutionReinsertPointWithaOut;
            solutionNoTsa=solutionaReinsertOut;
            TsRelationshipNoTs(a,1)=0;
            TsRelationshipNoTs(PointTsWithA,1)=0;
            TsRelationshipNoTs(a,2)=0;
            TsRelationshipNoTs(PointTsWithA,2)=0;
        end
        if TsRelationship(b,1)~=0%%%两列车辆数行
            PointTsWithB=TsRelationship(b,1);
            display([ num2str(b) ' and ' num2str(PointTsWithB) ' are related' ]);
            solutionbReinsert=solutionOrib;
            solutionReinsertPointWithb=currentsolutioncell{PointTsWithB,1};
            solutionbReinsert=solutionbReinsert(solutionbReinsert<=demand);
            solutionReinsertPointWithb=solutionReinsertPointWithb(solutionReinsertPointWithb<=demand);
            [YNb,solutionbReinsertOut] = BackToNoTs(b,currentsolutioncell,CurrentNoTsSolutionCell,TsRelationship,demand,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,TS,depotendtime,vhccapacity,fixedcost,cwk,ctk,vhcdepot,des_option,rep_option,TravelTimeMax,op,tsop,SetTsMax,EachOptionMax,iteration,solutionbReinsert);
            [YNbb,solutionReinsertPointWithbOut] = BackToNoTs(PointTsWithB,currentsolutioncell,CurrentNoTsSolutionCell,TsRelationship,demand,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,TS,depotendtime,vhccapacity,fixedcost,cwk,ctk,vhcdepot,des_option,rep_option,TravelTimeMax,op,tsop,SetTsMax,EachOptionMax,iteration,solutionReinsertPointWithb);
            display([ num2str(b) ':  ' num2str(YNb) ',' num2str(PointTsWithB) ':  ' num2str(YNbb) ]);
            NoTsSolutioncell{b,1}=solutionbReinsertOut;
            NoTsSolutioncell{PointTsWithB,1}=solutionReinsertPointWithbOut;
            solutionNoTsb=solutionbReinsertOut;
            TsRelationshipNoTs(b,1)=0;
            TsRelationshipNoTs(PointTsWithB,1)=0;
            TsRelationshipNoTs(b,2)=0;
            TsRelationshipNoTs(PointTsWithB,2)=0;
        end
        
        if YNa&&YNaa&&YNb&&YNbb
            TsRelationship
            YNback=1;
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    SZA = size(solutionNoTsa,2);%%%车辆链A中有几个点？
    SZB = size(solutionNoTsb,2);%%%车辆链B中有几个点？
    YN=0;
    TooMuchOrNot=0;
    CountNum=0;
    display(['Chain' num2str(a) ' and Chain' num2str(b) ' are being processed']);
    while YN==0&&TooMuchOrNot==0
        CountNum=CountNum+1;
        if CountNum>=5
            TooMuchOrNot=1;
        end
        %% DestroyOperator
        if des_option==1
            [ DeteleNumA,DeteleNumB,DemandEList,DemandFList ] = DestroyOperator1( r,a,b,solutionNoTsa,solutionNoTsb,demand,NoTsSolutioncell,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,TS,depotendtime,vhccapacity,fixedcost,cwk,ctk,vhcdepot );
        elseif des_option==2
            [ DeteleNumA,DeteleNumB,DemandEList,DemandFList ] = DestroyOperator2( r,a,b,solutionNoTsa,solutionNoTsb,demand,NoTsSolutioncell,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,TS,depotendtime,vhccapacity,fixedcost,cwk,ctk,vhcdepot );
        elseif des_option==3
            [ DeteleNumA,DeteleNumB,DemandEList,DemandFList ] = DestroyOperator3( r,a,b,solutionNoTsa,solutionNoTsb,demand,NoTsSolutioncell,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,TS,depotendtime,vhccapacity,fixedcost,cwk,ctk,vhcdepot );
        elseif des_option==4
            [ DeteleNumA,DemandEList ] = DestroyOperator4( r,a,solutionNoTsa,demand,NoTsSolutioncell );
            [ DeteleNumB,DemandFList ] = DestroyOperator4( r,b,solutionNoTsb,demand,NoTsSolutioncell );
        elseif des_option==5
            [ DeteleNumA,DemandEList ] = DestroyOperator5( a,solutionNoTsa,NoTsSolutioncell,demand,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,TS,depotendtime,vhccapacity,fixedcost,cwk,ctk,vhcdepot );
            [ DeteleNumB,DemandFList ] = DestroyOperator5( b,solutionNoTsb,NoTsSolutioncell,demand,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,TS,depotendtime,vhccapacity,fixedcost,cwk,ctk,vhcdepot );
        end
        display('I am at 107!!!!!!!!!!!!!!!!!!!!!!!!!');
        AwithoutEE=solutionNoTsa;
        BwithoutFF=solutionNoTsb;
        for j=1:DeteleNumA
            DemandE=DemandEList(1,j);
            AwithoutEE=AwithoutEE(AwithoutEE~=DemandE+demand);
            AwithoutEE=AwithoutEE(AwithoutEE~=DemandE);
        end
        for j=1:DeteleNumB
            DemandF=DemandFList(1,j);
            BwithoutFF=BwithoutFF(BwithoutFF~=DemandF+demand);
            BwithoutFF=BwithoutFF(BwithoutFF~=DemandF);
        end
        SZAxE=SZA-DeteleNumA*2;
        SZBxF=SZB-DeteleNumB*2;
        %% RepairOperator
        if rep_option==1
            [ YNA,AwithFF,InsertPositionA ] = RepairOperator1_0803( AwithoutEE,DeteleNumB,DemandFList,a,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,demand,NoTsSolutioncell,vhccapacity,fixedcost,cwk,ctk,TravelTimeMax,op,tsop );
            if YNA==0
                continue
            end
            [ YNB,BwithEE,InsertPositionB ] = RepairOperator1_0803( BwithoutFF,DeteleNumA,DemandEList,b,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,demand,NoTsSolutioncell,vhccapacity,fixedcost,cwk,ctk,TravelTimeMax,op,tsop );
            if YNA&&YNB
                YN=1;
                break
            else
                YN=0;
                continue
            end
        elseif rep_option==2
            [ YNA,AwithFF,InsertPositionA ] = RepairOperator2_0426( AwithoutEE,DeteleNumB,DemandFList,a,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,demand,NoTsSolutioncell,vhccapacity,fixedcost,cwk,ctk,TravelTimeMax,op,tsop );
            if YNA==0
                YN=0;
                continue
            end
            [ YNB,BwithEE,InsertPositionB ] = RepairOperator2_0426( BwithoutFF,DeteleNumA,DemandEList,b,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,demand,NoTsSolutioncell,vhccapacity,fixedcost,cwk,ctk,TravelTimeMax,op,tsop );
            if YNA&&YNB
                YN=1;
                break
            else
                TooMuchOrNot=1;
                YN=0;
            end
            %%elseif rep_option==3
        end
    end
    if YN==1
        NoTsSolutioncell{a,1}=AwithFF;
        NoTsSolutioncell{b,1}=BwithEE;
        if des_option==1||des_option==2||des_option==3
            tablesolutionneig = [1,a,DemandEList(1),InsertPositionA(1),b,DemandFList(1),InsertPositionB(1)];
        elseif des_option==4||des_option==5
            tablesolutionneig = [2,a,DemandEList(1),InsertPositionA(1),b,DemandFList(1),InsertPositionB(1)];
        end
    end
end
display('I am at 162!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
%%%%%%%%%%%%%%%%%%%%%%%%TS部分
display(['Transfering, Chain' num2str(a) ' and Chain' num2str(b) ' are being proceeded']);
[SetTs] = TransitOrNotAndWhere0421(AwithFF,BwithEE,vhcdepot,a,b,demand,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,TS,depotendtime,vhccapacity,fixedcost,cwk,ctk,op,tsop);
if isempty(SetTs)
    display('Ts is impossible');
end
[ BestAlloverSolutionTs,BestAllOverCostTs ] = TsBestSolutionALNS0711( NoTsSolutioncell,SetTs,AwithFF,BwithEE,TS,demand,DemandF,InsertPositionA,a,DemandE,InsertPositionB,b,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,vhccapacity,fixedcost,cwk,ctk,TravelTimeMax,op,tsop,SetTsMax,EachOptionMax );
TsRelationNewWithTS=TsRelationshipNoTs;
if isempty(BestAlloverSolutionTs)
    BestAlloverSolutionTs=NoTsSolutioncell;
    BestAllOverCostTs=999999999999;
end
BestAllSolutionTs=BestAlloverSolutionTs;
TsRelationNewWithTS(a,1)=b;
TsRelationNewWithTS(b,1)=a;
TsRelationNewWithTS(a,2)=iteration;
TsRelationNewWithTS(b,2)=iteration;
end

