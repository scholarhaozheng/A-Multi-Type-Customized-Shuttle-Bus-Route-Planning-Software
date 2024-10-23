function [ DeteleNumA,DemandEList ] = DestroyOperator4( r,a,solutionNoTsa,demand,NoTsSolutioncell )
SZA = size(solutionNoTsa,2);%%%车辆链A中有几个点？
e = randi([1 SZA],1);   %%%交换车辆链中的哪一点之后的点？
DemandE=solutionNoTsa(1,e);
if DemandE > demand     %%保证e的位置是上车点,demand一共有100个，大于100个即为下车点
    DemandE = DemandE-demand;
    [~,e]=find(solutionNoTsa==DemandE);
end
DemandEList=solutionNoTsa(1,e:end);
DemandEList=DemandEList(DemandEList<=demand);
DeteleNumA=size(DemandEList,2);
%%%%%%%%
end

