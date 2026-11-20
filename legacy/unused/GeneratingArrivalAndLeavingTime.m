function [YN,TimeArriving,TimeLeaving]=GeneratingArrivalAndLeavingTime(solution,vhcindex,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,demand,op,tsop)
demandtime=[demandstarttime;demandendtime];
M = size(solution,2);
TimeArriving=zeros(1,M);
TimeLeaving=zeros(1,M);
%%%% YN=1：车辆链符合约束
YN = 1;
if (M ~= 0)
    Tbegin = vhcstarttime(vhcindex,1); %%时间窗上限发车
    FstNode = solution(1,1);%%%%车辆链中的第一个节点
    TravelTime = vhcdemandtimematrix(vhcindex,FstNode);%%%车辆从出发点a到d需要走多久
    %%%%%%车辆链中第一个节点是否可以被服务
    TimeArriving(1,1)=Tbegin + TravelTime;
    TimeLeaving(1,1)=TimeArriving(1,1)+op;
    if TimeArriving(1,1) > demandstarttime(FstNode,2)%%%车辆链中第一个节点最晚到达时间
        YN = 0;
    else%%%%当第一个节点可以被服务时
        for i = 1:M-1
            u = solution(1,i);
            uPone = solution(1,i+1);
            TravelTime =  timematrix(uPone,u);
            TimeArrive=TravelTime+TimeLeaving(1,i);
            if solution(1,i+1)<=2*demand
                if TimeArrive <= demandtime(uPone,2)
                    if TimeArrive <= demandtime(uPone,1)
                        TimeArriving(1,i+1) = demandtime(uPone,1);
                    else
                        TimeArriving(1,i+1)=TimeArrive;
                    end
                else
                    YN = 0;
                    break
                end
                TimeLeaving(1,i+1)=TimeArriving(1,i+1)+op;
            else
                TimeArriving(1,i+1)=TimeArrive;
                TimeLeaving(1,i+1)=TimeArriving(1,i)+tsop;
            end
        end
        %%%%%%完成所有点能否被服务的判断
        if YN==1
            if TimeArriving(1,M) + vhcdemandtimematrix(vhcindex,solution(1,M)) > vhcendtime(vhcindex,2)
                YN=0;
            end
        end
        %%%%%%完成是否满足车辆时间窗下限的判断
    end
end
