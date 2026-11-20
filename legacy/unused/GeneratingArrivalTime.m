function [YN,TimeArriving]=GeneratingArrivalTime(solution,vhcindex,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,demand)
demandtime=[demandstarttime;demandendtime];
solution=solution';
M = size(solution,2);
TimeArriving=zeros(1,M);
solution_test=solution;
for i=1:M
    Test=solution_test(M-i+1);
    solution_test(M-i+1)=[];
    if ismember(Test,solution_test)==1
        solution_test
        solution
        display('Stop!!!!');
        sss
    else
    end
end
if solution(1,1)>100
    solution
    pause(10000)
end
%%%% YN=1：车辆链符合约束
YN = 1;
if (M ~= 0)
    Tbegin = vhcstarttime(vhcindex,1); %%时间窗上限发车
    FstNode = solution(1,1);%%%%车辆链中的第一个节点
    TravelTime = vhcdemandtimematrix(vhcindex,FstNode);%%%车辆从出发点a到d需要走多久
    %%%%%%车辆链中第一个节点是否可以被服务
    TimeArriving(1,1)=Tbegin + TravelTime;
    if TimeArriving(1,1) > demandstarttime(FstNode,2)%%%车辆链中第一个节点最晚到达时间
        YN = 0;
    else%%%%当第一个节点可以被服务时
        for i = 1:M-1
            u = solution(1,i);
            uPone = solution(1,i+1);
            TravelTime =  timematrix(uPone,u);
            TimeArrive=TravelTime+TimeArriving(1,i);
            if uPone>2*demand
                continue                
            else
                if TimeArrive <= demandtime(uPone,2)
                    if TimeArrive <= demandtime(uPone,1)
                        TimeArriving(1,i+1) = demandtime(uPone,1);
                    else
                        TimeArriving(1,i+1)=TimeArrive;
                    end
                else
                    YN = 0;
                end
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
% if Tbegin + t0 <= demandstarttime(d,2)
%     if Tbegin + t0 <= demandstarttime(d,1)
%         t0 = demandstarttime(d,1);
%     else
%         t0 = t0 + Tbegin;
%     end
% else
%     YN = 0;
% end
% for i = 1:M-1
%     u = solution(1,i);
%     v = solution(1,i+1);
%     t0 = t0 + timematrix(u,u)+timematrix(v,u);
%     if t0 <= demandstarttime(v,2)
%         if t0 <= demandstarttime(v,1)
%             t0 = demandstarttime(v,1);
%         end
%     else
%         YN = 0;
%         return
%     end
% end
% YN = 1;
% return