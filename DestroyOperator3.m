function [ DeteleNumA,DeteleNumB,DemandEList,DemandFList ] = DestroyOperator3( r,a,b,solutionNoTsa,solutionNoTsb,demand,NoTsSolutioncell,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,TS,depotendtime,vhccapacity,fixedcost,cwk,ctk,vhcdepot )
SZA = size(solutionNoTsa,2);%%%车辆链A中有几个点？
SZB = size(solutionNoTsb,2);%%%车辆链B中有几个点？
demandtime=[demandstarttime;demandendtime];
DeteleNumA=ceil(SZA*r);
DeteleNumB=ceil(SZB*r);
if DeteleNumA>DeteleNumB
    DeteleNumA=DeteleNumB;
elseif DeteleNumA<DeteleNumB
    DeteleNumB=DeteleNumA;
end
eList=zeros(1,DeteleNumA);
fList=zeros(1,DeteleNumB);
DemandEList=zeros(1,DeteleNumA);
DemandFList=zeros(1,DeteleNumB);
phi=1;
kappa=1;
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
for j=1:DeteleNumB
    Relateness=99999*ones(1,SZB);
    for ii=1:SZB
        if solutionNoTsb(1,ii)>demand
            continue
        end
        DemandF=solutionNoTsb(1,ii);
        Relateness(1,ii)=phi*timematrix(DemandEList(j),DemandF)+kappa*abs((demandtime(DemandEList(j),1)-demandtime(DemandF,1)));
    end
    Relateness_use=Relateness;
    numf=0;
    while numf<1
        [~,index_f]=min(Relateness_use);
        f=index_f;
        if ismember( f,fList )==0
            fList(1,j)=f;
            DemandF=solutionNoTsb(1,f);
            DemandFList(1,j)=DemandF;
            numf=numf+1;
            j=j+1;
        else
            Relateness_use(1,index_f)=99999;
            continue
        end
    end
end

end

