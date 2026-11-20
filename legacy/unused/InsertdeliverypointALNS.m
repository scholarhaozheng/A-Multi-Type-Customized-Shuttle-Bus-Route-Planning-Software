function [YON,solution] = InsertdeliverypointALNS0711(AwithFF,TS_point,TsAfterThis,BTsToA,ATsToB,demand,DemandF,epos,index,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,vhccapacity,fixedcost,cwk,ctk,TravelTimeMax,op,tsop)
%%%%%%%%%%%%%上车点满足时间窗插入满足条件的下车点
%%%%%%%%%%%%%这里输入的solutiona是带其他下车点，只不带刚刚交换的pickpoint的下车点的
%%%%%%%%%%%%%TS position是与solutiona的情况匹配的
%%%%%%%%%%%%%先插TS点，然后插其他下车需求点，不用管上车需求点
YN=0;
yn=1;
M = size(AwithFF,2);
if TsAfterThis==M
    AwithFFTS=[AwithFF(1,1:TsAfterThis),TS_point];
else
    AwithFFTS=[AwithFF(1,1:TsAfterThis),TS_point,AwithFF(1,TsAfterThis+1:M)];
end
ATsToBdelivery=ATsToB+demand;
AFFxATsToB=AwithFFTS;
for i=1:size(ATsToB,2)
    AFFxATsToB=AwithFFTS(AwithFFTS~=ATsToBdelivery(i));
end
% % TsFOrNot=find(ATsToB==DemandF);
% % if isempty(TsFOrNot)
% %     DemandsAneedToDeliver=[BTsToA,DemandF];
% % else
% %     DemandsAneedToDeliver=BTsToA;
% % end
if size(BTsToA,2)==0
    solution=AFFxATsToB;
    YN=1;
    YNcapacity=1;
else
    a_insert=AFFxATsToB;
    [~,TSpositionNew]=find(AFFxATsToB==TS_point);
    for i=1:size(BTsToA,2)
        aLastRound=a_insert;
        sizea=size(a_insert,2);
        for j=TSpositionNew:sizea
            if j==sizea
                aPart1=a_insert(1,1:j);
                aPart2=[];
            else
                aPart1=a_insert(1,1:j);
                aPart2=a_insert(1,j+1:sizea);
            end
            a_insert=[aPart1,demand+BTsToA(i),aPart2];
            yn = judgement_op(a_insert,index,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,demand,op,tsop);
            [ YNtime ] = CalculatingTotalTime(index,a_insert,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk,TravelTimeMax);
            if yn==1||YNtime==1
                break
            else
                a_insert=aLastRound;
            end
        end
        if yn == 0
            YN=0;
            solution=[];
            break
        else
            YN=1;
            solution=a_insert;
        end
    end
    [ YNcapacity ] = CapacityCheck(index,solution,demand,vhccapacity);
end
if YNcapacity==1&&YN==1
    YON=1;
else
    YON=0;
end
