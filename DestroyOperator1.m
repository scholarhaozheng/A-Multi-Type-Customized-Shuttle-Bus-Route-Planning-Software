function [ DeteleNumA,DeteleNumB,DemandEList,DemandFList ] = DestroyOperator1( r,a,b,solutionNoTsa,solutionNoTsb,demand,NoTsSolutioncell,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,TS,depotendtime,vhccapacity,fixedcost,cwk,ctk,vhcdepot )
SZA = size(solutionNoTsa,2);%%%车辆链A中有几个点？
SZB = size(solutionNoTsb,2);%%%车辆链B中有几个点？
DeteleNumA=ceil(SZA*r);
DeteleNumB=ceil(SZB*r);
eList=zeros(1,DeteleNumA);
fList=zeros(1,DeteleNumB);
DemandEList=zeros(1,DeteleNumA);
DemandFList=zeros(1,DeteleNumB);
SelectedA=0;
while SelectedA<DeteleNumA
    e = randi([1 SZA],1);   %%%交换车辆链中的哪一点？
    DemandE=solutionNoTsa(1,e);
    if DemandE > demand     %%保证e的位置是上车点,demand一共有100个，大于100个即为下车点
        DemandE = DemandE-demand;
        [~,e]=find(solutionNoTsa==DemandE);
    end
    if ismember( e,eList )==0
        SelectedA=SelectedA+1;
        eList(1,SelectedA)=e;
        DemandEList(1,SelectedA)=DemandE;
    else
        continue
    end
end
SelectedB=0;
while SelectedB<DeteleNumB
    f = randi([1 SZB],1);   %%%交换车辆链中的哪一点？
    DemandF=solutionNoTsb(1,f);
    if DemandF > demand     %%保证e的位置是上车点,demand一共有100个，大于100个即为下车点
        DemandF = DemandF-demand;
        [~,f]=find(solutionNoTsb==DemandF);
    end
    if ismember( f,fList )==0
        SelectedB=SelectedB+1;
        fList(1,SelectedB)=f;
        DemandFList(1,SelectedB)=DemandF;
    else
        continue
    end
end

end

