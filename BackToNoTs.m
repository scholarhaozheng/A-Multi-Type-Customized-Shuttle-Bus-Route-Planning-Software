function [YN,solutionaReinsertOut] = BackToNoTs0504(index,currentsolutioncell,CurrentNoTsSolutionCell,TsRelationship,demand,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,TS,depotendtime,vhccapacity,fixedcost,cwk,ctk,vhcdepot,des_option,rep_option,TravelTimeMax,op,tsop,SetTsMax,EachOptionMax,iteration,solutionaReinsert)
%UNTITLED4 此处显示有关此函数的摘要
%   此处显示详细说明
YN=0;
yn=0;
aInsertList=solutionaReinsert;
solutionaReinsertOri=solutionaReinsert;
aInsertListOptionsOri=perms(aInsertList);
NumaInsertListOptions=[];
aInsertListOptions=aInsertListOptionsOri;
if size(aInsertListOptionsOri,1)>8
    aInsertListOptions=[];
    while size(NumaInsertListOptions,2)<8
        add=randi(ceil(size(aInsertListOptionsOri,1)));
        if find(NumaInsertListOptions==add)
            continue
        end
        NumaInsertListOptions=[NumaInsertListOptions,add];
    end
    for k=1:size(NumaInsertListOptions,2)
        aInsertListOptions=[aInsertListOptions;aInsertListOptionsOri(NumaInsertListOptions(1,k),:)];
    end
end

for kk=1:size(aInsertListOptions,1)
    solutionaReinsert=solutionaReinsertOri;
    aInsertList=aInsertListOptions(kk,:);
    a_insert=solutionaReinsert;
    for i=1:size(aInsertList,2)
        aLastRound=a_insert;
        sizea=size(a_insert,2);
        a_insert=solutionaReinsert;
        [~,positionNew]=find(aLastRound==aInsertList(i));
        for j=positionNew:sizea
            if j==sizea
                aPart1=a_insert(1,1:j);
                aPart2=[];
            else
                aPart1=a_insert(1,1:j);
                aPart2=a_insert(1,j+1:sizea);
            end
            a_insert=[aPart1,demand+aInsertList(i),aPart2];
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
            solutionaReinsert=[];
            break
        else
            YN=1;
            solutionaReinsert=a_insert;
        end
        if i==size(aInsertList,2)
            [ YNcapacity ] = CapacityCheck(a,solutionaReinsert,demand,vhccapacity);
            if YNcapacity==0
                YN=0;
            end
        end
    end
    if YN==1
        solutionaReinsertOut=solutionaReinsert;
        break
    end
end
if YN==0
    solutionaReinsertOut=[];
end


