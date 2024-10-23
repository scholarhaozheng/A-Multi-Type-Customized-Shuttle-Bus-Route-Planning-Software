function [YN,TimeArriving,TimeLeaving]=GeneratingArrivalAndLeavingTime(solution,vhcindex,vhcstarttime,vhcendtime,demandstarttime,demandendtime,timematrix,vhcdemandtimematrix,demand,op,tsop)
demandtime=[demandstarttime;demandendtime];
M = size(solution,2);
TimeArriving=zeros(1,M);
TimeLeaving=zeros(1,M);
%%%% YN=1������������Լ��
YN = 1;
if (M ~= 0)
    Tbegin = vhcstarttime(vhcindex,1); %%ʱ�䴰���޷���
    FstNode = solution(1,1);%%%%�������еĵ�һ���ڵ�
    TravelTime = vhcdemandtimematrix(vhcindex,FstNode);%%%�����ӳ�����a��d��Ҫ�߶��
    %%%%%%�������е�һ���ڵ��Ƿ���Ա�����
    TimeArriving(1,1)=Tbegin + TravelTime;
    TimeLeaving(1,1)=TimeArriving(1,1)+op;
    if TimeArriving(1,1) > demandstarttime(FstNode,2)%%%�������е�һ���ڵ���������ʱ��
        YN = 0;
    else%%%%����һ���ڵ���Ա�����ʱ
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
        %%%%%%������е��ܷ񱻷�����ж�
        if YN==1
            if TimeArriving(1,M) + vhcdemandtimematrix(vhcindex,solution(1,M)) > vhcendtime(vhcindex,2)
                YN=0;
            end
        end
        %%%%%%����Ƿ����㳵��ʱ�䴰���޵��ж�
    end
end