function [ BestAlloverSolutionTs,BestAllOverCostTs ] = TsBestSolutionALNS0711( currentsolutioncell,SetTsOri,AwithFF,BwithEE,TS,demand,pickuppointA,pickuppointlocationA,a,pickuppointB,pickuppointlocationB,b,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,vhccapacity,fixedcost,cwk,ctk,TravelTimeMax,op,tsop,SetTsMax,EachOptionMax)
%%输入：solution中不包括TS点,包括除将要交换的点之外的所有下车点,将要插入的点已经插入
%%输出：在Insert函数之前，此时solution中包括TS点，包括下车点
sizeTS=size(SetTsOri,1);

%%%Solution a[1,2,5,91], solutionb[4,3,7,21]
%%%[2,1,TS1](solution a中的第二个位置，solution b中的第一个位置)
% % SetTS=[3,4,207;3,1,205;
% %     ];
% % solutiona=[11,12,13,91];
% % solutionb=[15,16,17,18,19,20,21];
% % sizeTS=size(SetTS,1);
% % numBestsolution=0;
NumSetTsProceeding=[];

if size(SetTsOri,1)>SetTsMax
    while size(NumSetTsProceeding,2)<SetTsMax
        add=randi(size(SetTsOri,1));
        if find(NumSetTsProceeding==add)
            continue
        end
        NumSetTsProceeding=[NumSetTsProceeding,add];
    end
    SetTs=[];
    for k=1:size(NumSetTsProceeding,2)
        SetTs=[SetTs;SetTsOri(NumSetTsProceeding(1,k),:)];
    end
else
    SetTs=SetTsOri;
end

sizeTS=size(SetTs,1);
demandtime=[demandstarttime;demandendtime];
TS_solution=currentsolutioncell;
BestAllOverCostTs=88888;
BestAlloverSolutionTs={};
TransOptionCosts=88888*ones(1,sizeTS);
numTransOption=0;
if sizeTS==0
    BestAlloverSolutionTs={};
    BestAllOverCostTs=8888888888;
else
    BestWayOfTransferAfterInsertingTS=cell(1,sizeTS);
    for i=1:sizeTS
        %%对于每种TS点插入方式%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        TS_point=SetTs(i,5);
        positionA=SetTs(i,1);
        positionB=SetTs(i,2);
        DemandA=AwithFF(1,positionA);
        DemandB=BwithEE(1,positionB);
        DemandWaitForTsA=AwithFF(1,1:positionA);%%%%%%%nodes(28,23,34)而不是序列数(1,2,3)
        DemandWaitForTsB=BwithEE(1,1:positionB);
        DemandWaitForTsA=DemandWaitForTsA(DemandWaitForTsA<=demand);
        DemandWaitForTsB=DemandWaitForTsB(DemandWaitForTsB<=demand);
        SizeDmndWtFrTsA=size(DemandWaitForTsA,2);
        SizeDmndWtFrTsB=size(DemandWaitForTsB,2);
        for j=1:SizeDmndWtFrTsA
            NodeProceeding=DemandWaitForTsA(1,j);
            EarliestReachDeliveryA=SetTs(i,6)+timematrix(TS_point,NodeProceeding+demand);
            if EarliestReachDeliveryA>demandtime(NodeProceeding+demand,2)
                DemandWaitForTsA(1,j)=999;
            end
        end
        for j=1:SizeDmndWtFrTsB
            NodeProceeding=DemandWaitForTsB(1,j);
            EarliestReachDeliveryB=SetTs(i,6)+timematrix(TS_point,NodeProceeding+demand);
            if EarliestReachDeliveryB>demandtime(NodeProceeding+demand,2)
                DemandWaitForTsB(1,j)=999;
            end
        end
        DemandWaitForTsA=DemandWaitForTsA(DemandWaitForTsA~=999);
        DemandWaitForTsB=DemandWaitForTsB(DemandWaitForTsB~=999);
        %%%%%将其中的下车点拿掉
        SizeTsA=size(DemandWaitForTsA,2);
        SizeTsB=size(DemandWaitForTsB,2);
        A_TS_conbinations_cell={};
        B_TS_conbinations_cell={};
        for j=0:SizeTsA
            if j==0
                A_TS_conbinations_cell{j+1}=[];
            else
                add=nchoosek(DemandWaitForTsA,j);
                A_TS_conbinations_cell{j+1}=add;
            end
        end
        for j=0:SizeTsB
            if j==0
                B_TS_conbinations_cell{j+1}=[];
            else
                add=nchoosek(DemandWaitForTsB,j);
                B_TS_conbinations_cell{j+1}=add;
            end
        end
        TransOption={};
        for j=1:size(A_TS_conbinations_cell,2)
            for k=1:size(B_TS_conbinations_cell,2)
                add1=A_TS_conbinations_cell{j};
                add2=B_TS_conbinations_cell{k};
                add={add1;add2};
                TransOption{(j-1)*size(B_TS_conbinations_cell,2)+k}=add;
            end
        end
        NumOption=size(TransOption,2);
        TS_successful_num=0;
        TsSuccessfulCosts=[];
        TsSuccessfulSolutions={};
        Acouldnot={};
        Bcouldnot={};
        AcouldnotCount=0;
        BcouldnotCount=0;
        NumOptionProceeding=[];
        if size(TransOption,2)>EachOptionMax
            while size(NumOptionProceeding,2)<EachOptionMax
                add=randi(NumOption);
                if find(NumOptionProceeding==add)
                    continue
                end
                NumOptionProceeding=[NumOptionProceeding,add];
            end
            TransOptionProceeding=cell(1,EachOptionMax);
            for k=1:size(NumOptionProceeding,2)
                TransOptionProceeding{1,k}=TransOption{1,NumOptionProceeding(1,k)};
            end
        else
            TransOptionProceeding=TransOption;
        end
        Sizeoptions=size(TransOptionProceeding,2);
        for j=1:Sizeoptions
            %%%%%%%%%%%%%%%%%对于每种下车需求点交换方式组
            option_proceeding=TransOptionProceeding{1,j};
            ATsToB_options=option_proceeding{1,1};
            BTsToA_options=option_proceeding{2,1};
            %display(['size(BTsToA_options,1):' num2str(size(BTsToA_options,1))]);
            %display(['size(ATsToB_options,1):' num2str(size(ATsToB_options,1))]);
            if isempty(ATsToB_options)&&isempty(BTsToA_options)
                continue
            elseif isempty(ATsToB_options)
                for l=1:size(BTsToA_options,1)
                    %%%%%%%%%%%%%对于组中的每种TS点交换方式
                    ATsToB=[];
                    BTsToA=BTsToA_options(l,:);
                    %%%%%%%%
                    YN=1;
                    for m=1:size(Acouldnot,1)
                        Test=Acouldnot{m,:};
                        SameElements=intersect(Test,BTsToA);
                        Test=intersect(Test,Test);
                        if isequal(SameElements,Test)
                            YN=0;
                            break
                        end
                    end
                    if YN==0
                        YNA=0;
                        YNB=0;
                        continue
                    end
                    for m=1:size(Bcouldnot,1)
                        Test=Bcouldnot{m,:};
                        SameElements=intersect(Test,ATsToB);
                        Test=intersect(Test,Test);
                        if isequal(SameElements,Test)
                            YN=0;
                            break
                        end
                    end
                    if YN==0
                        YNA=0;
                        YNB=0;
                        continue
                    end
                    %%%%%%%%
                    [YNA,solutionAnew] = InsertdeliverypointALNS0711(AwithFF,TS_point,positionA,BTsToA,ATsToB,demand,pickuppointA,pickuppointlocationA,a,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,vhccapacity,fixedcost,cwk,ctk,TravelTimeMax,op,tsop);
                    if YNA==0
                        YNB=0;
                        AcouldnotCount=AcouldnotCount+1;
                        Acouldnot{AcouldnotCount,1}=BTsToA;
                        continue
                    end
                    [YNB,solutionBnew] = InsertdeliverypointALNS0711(BwithEE,TS_point,positionB,ATsToB,BTsToA,demand,pickuppointB,pickuppointlocationB,b,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,vhccapacity,fixedcost,cwk,ctk,TravelTimeMax,op,tsop);
                    if YNB==0
                        BcouldnotCount=BcouldnotCount+1;
                        Bcouldnot{BcouldnotCount,1}=ATsToB;
                    end
                    TS_solution{a,1}=solutionAnew;
                    TS_solution{b,1}=solutionBnew;
                    if YNA&&YNB
                        [TsSuccessfulCost,~] = calculatetotalcost_test(TS_solution,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk);
                        TS_successful_num=TS_successful_num+1;
                        TsSuccessfulCosts(TS_successful_num)=TsSuccessfulCost;
                        TsSuccessfulSolutions{TS_successful_num}=TS_solution;
                        % %                         WrongOrNotA=find(solutionAnew==201);
                        % %                         WrongOrNotB=find(solutionBnew==201);
                        % %                         if isempty(WrongOrNotA)
                        % %                             display(['ATsToB_options is empty Wrong A! l=' num2str(l)]);
                        % %                             BTsToA
                        % %                             save Debug0225.mat
                        % %                             pause(600000);
                        % %                         end
                        % %                         if isempty(WrongOrNotB)
                        % %                             display(['ATsToB_options is empty Wrong B!l=' num2str(l)])
                        % %                             BTsToA
                        % %                             save Debug0225.mat
                        % %                             pause(600000);
                        % %                         end
                    end
                end
            elseif isempty(BTsToA_options)
                for k=1:size(ATsToB_options,1)
                    BTsToA=[];
                    ATsToB=ATsToB_options(k,:);
                    %%%%%%%%
                    YN=1;
                    for m=1:size(Acouldnot,1)
                        Test=Acouldnot{m,:};
                        SameElements=intersect(Test,BTsToA);
                        Test=intersect(Test,Test);
                        if isequal(SameElements,Test)
                            YN=0;
                            break
                        end
                    end
                    if YN==0
                        YNA=0;
                        YNB=0;
                        continue
                    end
                    for m=1:size(Bcouldnot,1)
                        Test=Bcouldnot{m,:};
                        SameElements=intersect(Test,ATsToB);
                        Test=intersect(Test,Test);
                        if isequal(SameElements,Test)
                            YN=0;
                            break
                        end
                    end
                    if YN==0
                        YNA=0;
                        YNB=0;
                        continue
                    end
                    %%%%%%%%
                    for m=1:size(Acouldnot,1)
                        Test=Acouldnot{m,:};
                        SameElements=intersect(Test,BTsToA);
                        Test=intersect(Test,Test);
                        if isequal(SameElements,Test)
                            YN=0;
                            break
                        end
                    end
                    if YN==0
                        YNA=0;
                        YNB=0;
                        continue
                    end
                    for m=1:size(Bcouldnot,1)
                        Test=Bcouldnot{m,:};
                        SameElements=intersect(Test,ATsToB);
                        Test=intersect(Test,Test);
                        if isequal(SameElements,Test)
                            YN=0;
                            break
                        end
                    end
                    if YN==0
                        YNA=0;
                        YNB=0;
                        continue
                    end
                    [YNA,solutionAnew] = InsertdeliverypointALNS0711(AwithFF,TS_point,positionA,BTsToA,ATsToB,demand,pickuppointA,pickuppointlocationA,a,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,vhccapacity,fixedcost,cwk,ctk,TravelTimeMax,op,tsop);
                    if YNA==0
                        YNB=0;
                        AcouldnotCount=AcouldnotCount+1;
                        Acouldnot{AcouldnotCount,1}=BTsToA;
                        continue
                    end
                    [YNB,solutionBnew] = InsertdeliverypointALNS0711(BwithEE,TS_point,positionB,ATsToB,BTsToA,demand,pickuppointB,pickuppointlocationB,b,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,vhccapacity,fixedcost,cwk,ctk,TravelTimeMax,op,tsop);
                    if YNB==0
                        BcouldnotCount=BcouldnotCount+1;
                        Bcouldnot{BcouldnotCount,1}=ATsToB;
                    end
                    TS_solution{a,1}=solutionAnew;
                    TS_solution{b,1}=solutionBnew;
                    if YNA&&YNB
                        [TsSuccessfulCost,~] = calculatetotalcost_test(TS_solution,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk);
                        TS_successful_num=TS_successful_num+1;
                        TsSuccessfulCosts(TS_successful_num)=TsSuccessfulCost;
                        TsSuccessfulSolutions{TS_successful_num}=TS_solution;
                        % % %                         WrongOrNotA=find(solutionAnew==201);
                        % % %                         WrongOrNotB=find(solutionBnew==201);
                        % % %                         if isempty(WrongOrNotA)
                        % % %                             display(['BTsToA_options is empty Wrong A!k=' num2str(k)]);
                        % % %                             save Debug0225.mat
                        % % %                             pause(600000);
                        % % %                         end
                        % % %                         if isempty(WrongOrNotB)
                        % % %                             display(['BTsToA_options is empty Wrong B!k=' num2str(k)])
                        % % %                             save Debug0225.mat
                        % % %                             pause(600000);
                        % % %                         end
                    end
                end
            else
                for k=1:size(ATsToB_options,1)
                    ATsToB=ATsToB_options(k,:);
                    for l=1:size(BTsToA_options,1)
                        BTsToA=BTsToA_options(l,:);
                        %%%%%%%%
                        YN=1;
                        for m=1:size(Acouldnot,2)
                            Test=Acouldnot{m,:};
                            SameElements=intersect(Test,BTsToA);
                            Test=intersect(Test,Test);
                            if isequal(SameElements,Test)
                                YN=0;
                                break
                            end
                        end
                        if YN==0
                            YNA=0;
                            YNB=0;
                            continue
                        end
                        for m=1:size(Bcouldnot,2)
                            Test=Bcouldnot{m,:};
                            SameElements=intersect(Test,ATsToB);
                            Test=intersect(Test,Test);
                            if isequal(SameElements,Test)
                                YN=0;
                                break
                            end
                        end
                        if YN==0
                            YNA=0;
                            YNB=0;
                            continue
                        end
                        %%%%%%%%
                        [YNA,solutionAnew] = InsertdeliverypointALNS0711(AwithFF,TS_point,positionA,BTsToA,ATsToB,demand,pickuppointA,pickuppointlocationA,a,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,vhccapacity,fixedcost,cwk,ctk,TravelTimeMax,op,tsop);
                        if YNA==0
                            YNB=0;
                            AcouldnotCount=AcouldnotCount+1;
                            Acouldnot{AcouldnotCount,1}=BTsToA;
                            continue
                        end
                        [YNB,solutionBnew] = InsertdeliverypointALNS0711(BwithEE,TS_point,positionB,ATsToB,BTsToA,demand,pickuppointB,pickuppointlocationB,b,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,vhccapacity,fixedcost,cwk,ctk,TravelTimeMax,op,tsop);
                        if YNB==0
                            BcouldnotCount=BcouldnotCount+1;
                            Bcouldnot{BcouldnotCount,1}=ATsToB;
                        end
                        if YNA&&YNB
                            TS_solution=currentsolutioncell;
                            TS_solution{a,1}=solutionAnew;
                            TS_solution{b,1}=solutionBnew;
                            [TsSuccessfulCost,~] = calculatetotalcost_test(TS_solution,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk);
                            TS_successful_num=TS_successful_num+1;
                            TsSuccessfulCosts(TS_successful_num)=TsSuccessfulCost;
                            TsSuccessfulSolutions{TS_successful_num}=TS_solution;
                            % % %                             WrongOrNotA=find(solutionAnew==201);
                            % % %                             WrongOrNotB=find(solutionBnew==201);
                            % % %                             if isempty(WrongOrNotA)
                            % % %                                 display(['Wrong A!']);
                            % % %                                 save Debug0225.mat
                            % % %                                 pause(600000);
                            % % %                             end
                            % % %                             if isempty(WrongOrNotB)
                            % % %                                 display(['Wrong B!'])
                            % % %                                 save Debug0225.mat
                            % % %                                 pause(600000);
                            % % %                             end
                        end
                    end
                end
            end
            if isempty(TsSuccessfulCosts)
                continue
            end
            %%solution_original为没有delivery point和TS点的情况，
            %%TS为某点位置 TS点插入该点之后，BTsToA为A需要运送的额外点
        end
        if TS_successful_num==0
            continue
        end
        %%%%某种TS点插入方式的最优解
        [BestCostOfThisTS,SequenceBestTransOption]=min(TsSuccessfulCosts);
        BestTransOption=TsSuccessfulSolutions{1,SequenceBestTransOption};
        if isempty(BestTransOption)
            continue
        end
        numTransOption=numTransOption+1;
        BestWayOfTransferAfterInsertingTS{1,numTransOption}=BestTransOption;
        TransOptionCosts(1,numTransOption)=BestCostOfThisTS;
        %%display(['The best cost of NO.' num2str(i)  ' TSpoint is ' num2str(BestCostOfThisTS) ]);
    end
    [BestAllOverCostTs,SequenceBestAllOversolution]=min(TransOptionCosts);
    %%display(['BestAllOverCostTs is ' num2str(BestAllOverCostTs) ]);
    BestAlloverSolutionTs=BestWayOfTransferAfterInsertingTS{1,SequenceBestAllOversolution};
end

end

