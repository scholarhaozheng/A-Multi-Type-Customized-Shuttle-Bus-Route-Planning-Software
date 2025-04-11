function [ DeteleNumA,DemandEList ] = DestroyOperator5( a,solutionNoTsa,NoTsSolutioncell,demand,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,TS,depotendtime,vhccapacity,fixedcost,cwk,ctk,vhcdepot )
SZA = size(solutionNoTsa,2);
e = randi([1 SZA-1],1);   
DemandE=solutionNoTsa(1,e);
if DemandE > demand     
    DemandE = DemandE-demand;
    [~,e]=find(solutionNoTsa==DemandE);
end
DemandEList=solutionNoTsa(1,e:end);
DemandEList=DemandEList(DemandEList<=demand);
cost_listA=9999999999*ones(1,SZA);
DemandEListCell=cell(1,SZA);
segment_length=size(DemandEList,2);
DeteleNumA=segment_length;
for ii=1:SZA/2-segment_length+1
    ForChosenA=solutionNoTsa(solutionNoTsa<=demand);
    eList=[ii:ii+segment_length-1];
    DemandEList=ForChosenA(eList);
    NoTsSolutioncellUse=NoTsSolutioncell;
    for kk=1:size(DemandEList,2)
        DemandEDelete=DemandEList(1,kk);
        AwithoutEE=solutionNoTsa(solutionNoTsa~=DemandEDelete+demand);
        AwithoutEE=AwithoutEE(AwithoutEE~=DemandEDelete);
    end
    NoTsSolutioncellUse{a,1}=AwithoutEE;
    cost_listA(1,ii)=calculatetotalcost_test(NoTsSolutioncellUse,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk);
    DemandEListCell{1,ii}=DemandEList;
end
cost_listAuse= cost_listA;
[~,index]=min(cost_listAuse);
DemandEList=DemandEListCell{1,index};
%%%%%%%%



