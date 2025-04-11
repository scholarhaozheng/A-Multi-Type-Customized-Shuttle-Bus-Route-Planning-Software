function [ DeteleNumA,DemandEList ] = DestroyOperator4( r,a,solutionNoTsa,demand,NoTsSolutioncell )
SZA = size(solutionNoTsa,2);
e = randi([1 SZA],1);   
DemandE=solutionNoTsa(1,e);
if DemandE > demand    
    DemandE = DemandE-demand;
    [~,e]=find(solutionNoTsa==DemandE);
end
DemandEList=solutionNoTsa(1,e:end);
DemandEList=DemandEList(DemandEList<=demand);
DeteleNumA=size(DemandEList,2);
%%%%%%%%
end

