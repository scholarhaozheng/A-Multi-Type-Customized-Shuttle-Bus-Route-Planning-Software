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
%%%% YN=1������������Լ��
YN = 1;
if (M ~= 0)
    Tbegin = vhcstarttime(vhcindex,1); %%ʱ�䴰���޷���
    FstNode = solution(1,1);%%%%�������еĵ�һ���ڵ�
    TravelTime = vhcdemandtimematrix(vhcindex,FstNode);%%%�����ӳ�����a��d��Ҫ�߶��
    %%%%%%�������е�һ���ڵ��Ƿ���Ա�����
    TimeArriving(1,1)=Tbegin + TravelTime;
    if TimeArriving(1,1) > demandstarttime(FstNode,2)%%%�������е�һ���ڵ�������ʱ��
        YN = 0;
    else%%%%����һ���ڵ���Ա�����ʱ
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
        %%%%%%������е��ܷ񱻷�����ж�
        if YN==1
            if TimeArriving(1,M) + vhcdemandtimematrix(vhcindex,solution(1,M)) > vhcendtime(vhcindex,2)
                YN=0;
            end
        end
        %%%%%%����Ƿ����㳵��ʱ�䴰���޵��ж�
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