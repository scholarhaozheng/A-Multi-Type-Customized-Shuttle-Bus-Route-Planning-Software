function [ DeteleNumA,DeteleNumB,DemandEList,DemandFList ] = DestroyOperator2( r,a,b,solutionNoTsa,solutionNoTsb,demand,NoTsSolutioncell,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,TS,depotendtime,vhccapacity,fixedcost,cwk,ctk,vhcdepot )
SZA = size(solutionNoTsa,2);%%%车辆链A中有几个点？
SZB = size(solutionNoTsb,2);%%%车辆链B中有几个点？
DeteleNumA=ceil(SZA*r);
DeteleNumB=ceil(SZB*r);
eList=zeros(1,DeteleNumA);
fList=zeros(1,DeteleNumB);
DemandEList=zeros(1,DeteleNumA);
DemandFList=zeros(1,DeteleNumB);
SelectedA=0;
cost_listA=9999999999*ones(1,SZA);
for ii=1:SZA
    NoTsSolutioncellUse=NoTsSolutioncell;
    if solutionNoTsa(1,ii)>demand
        continue
    else
        AwithoutEE=solutionNoTsa(solutionNoTsa~=solutionNoTsa(1,ii)+demand);
        AwithoutEE=AwithoutEE(AwithoutEE~=AwithoutEE(1,ii));
        NoTsSolutioncellUse{a,1}=AwithoutEE;
        [cost_listA(1,ii),~]=calculatetotalcost_test(NoTsSolutioncellUse,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk);
    end
end
cost_listAuse= cost_listA;
for j=1:DeteleNumA
    [~,index_e]=min(cost_listAuse);
    e=index_e;
    DemandE=solutionNoTsa(1,e);
    eList(1,j)=e;
    DemandEList(1,j)=DemandE;
    cost_listAuse(1,index_e)=9999999999;
end
if size(eList,2)==2
    if eList(1,1)==eList(1,2)
        display('Stop here!!!! eList is wrong');
        eList
        pause(1000000)
    end
end
cost_listB=9999999999*ones(1,SZB);
for ii=1:SZB
    NoTsSolutioncellUse=NoTsSolutioncell;
    if solutionNoTsb(1,ii)>demand
        continue
    else
        BwithoutFF=solutionNoTsb(solutionNoTsb~=solutionNoTsb(1,ii)+demand);
        BwithoutFF=BwithoutFF(BwithoutFF~=BwithoutFF(1,ii));
        NoTsSolutioncellUse{b,1}=BwithoutFF;
        cost_listB(1,ii)=calculatetotalcost_test(NoTsSolutioncellUse,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk);
    end
end
cost_listBuse= cost_listB;
for j=1:DeteleNumB
    [~,index_f]=min(cost_listBuse);
    f=index_f;
    DemandF=solutionNoTsb(1,f);
    fList(1,j)=f;
    DemandFList(1,j)=DemandF;
    cost_listBuse(1,index_f)=9999999999;
end
if size(fList,2)==2
    if fList(1,1)==fList(1,2)
        display('Stop here!!!! fList is wrong');
        fList
        pause(1000000)
    end
end

end

