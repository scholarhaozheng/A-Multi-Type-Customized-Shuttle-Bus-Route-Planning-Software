clc;
clear all;
load gams10;
AMatrixArriveLeaveTime=zeros(16,3);
solutions=[];
TimeLeavings=[];
TimeArrivings=[];
bestsolution={[5,4,9,10]};
for ij=1:1
    solution=bestsolution{ij,1};
    if isempty(solution)
        continue
    end
    [YN,TimeLeaving,TimeArriving]=generateTime(solution,ij,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,demand,op,tsop);
    chainlength=length(solution);
    solution=[0,solution,zeros(1,15-chainlength)];
    TimeLeaving=[ij,TimeLeaving,zeros(1,15-chainlength)];
    TimeArriving=[0,TimeArriving,zeros(1,15-chainlength)];
    solutions=[solutions,solution];
    TimeLeavings=[TimeLeavings,TimeLeaving];
    TimeArrivings=[TimeArrivings,TimeArriving];
end
AMatrixArriveLeaveTime(:,1)=solutions';
AMatrixArriveLeaveTime(:,2)=TimeArrivings';
AMatrixArriveLeaveTime(:,3)=TimeLeavings';
mar=zeros(20,3);
for i=1:20
    pos=find(i==AMatrixArriveLeaveTime(:,1));
    mar(i,:)=AMatrixArriveLeaveTime(pos,:);
end
xlswrite('gams5_time.xlsx', mar, 'sheet1');
xlswrite('gams5_time.xlsx', AMatrixArriveLeaveTime, 'sheet1');




