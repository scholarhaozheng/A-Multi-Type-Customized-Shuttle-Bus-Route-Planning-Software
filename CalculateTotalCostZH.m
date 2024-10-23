function [Cost] = CalculateTotalCostZH(solutioncell,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk)
M = size(solutioncell,1);
demandtime=[demandstarttime;demandendtime];

%���������������������������������������ɱ���Ȩ��ϵ��
alpha_1 = 0.15;   %�ɱ�ϵ��
alpha_2 = 0.25;
alpha_3 = 0.3;
alpha_4 = 0.3;
beta_1 = 0.4;
beta_2 = 0.4;
beta_3 = 0.2;
alpha = 1000;     %�ͷ�����
beta = 1000;
gamma = 1000;

%���������������������������������������ɱ���ʼ��
Cost = 0;  %Ŀ�꺯��ֵ

C_fixedcost = 0; %�̶ܹ��ɱ�
C_traveltime = 0;     %������ʱ��ɱ�
C_patientonboardwaiting = 0;  %�ܳ˿��ڳ�ʱ��ɱ�
C_vehiclewaiting = 0;   %�ܳ����ȴ�ʱ��ɱ�
C = 0;     %��Ȩ�ܳɱ�

Quality_1 = 0;   %�ܷ�������1������ʱ��Ϊ��λ
Quality_2 = 0;   %�ܷ�������2
Quality_3 = 0;   %�ܷ�������3
Quality = 0;     %��Ȩ�ܷ�������

C_twpunishment = 0; %��ʱ�䴰�ͷ�
C_tipunishment = 0; %�ܳ�������ʱ��ͷ�
C_cpunishment = 0;  %�ܶ�ؿ����ͷ�
C_punishment = 0;   %�ܳͷ�


% c = 100; %����ݶ�ָ��ɱ�
c_1 = 10; %����ݶ�ָ��1�ɱ�
c_2 = 8; %����ݶ�ָ��2�ɱ�
c_3 = 2; %����ݶ�ָ��3�ɱ�
cpk = 3; %��λ�ڳ��˿͵ȴ�ʱ��ɱ�
Ti =timematrix.*3; %���˿��ڳ�ʱ��

for i = 1:M    %������ѭ��
    solution = solutioncell{i,1};
    k = size(solution,2);%����ÿ�����������ж��������
    if k == 0 
        c_twpunishment = 0;
        c_tipunishment = 0;
        c_cpunishment = 0;
        
        c_fixedcost = 0;
        c_traveltime = 0;
        c_patientonboardwaiting = 0;
        c_vehiclewaiting = 0;
        
        quality_1 = 0;
        quality_2 = 0;
        quality_3 = 0;
    else
        tw_vhc = zeros(k,1);   %�����ȴ�ʱ��
        tw_pas = zeros(k,1);   
        q =zeros(k,1);
       
         %���������������������������������������������������������������������������ȴ�ʱ�����
        d = solution(1,1);           
        Tbegin = vhcstarttime(i,1); 
        t0=0;
        t0 = vhcdemandtimematrix(i,d);
        Bi=zeros(k,1);
        if Tbegin + t0 <= demandstarttime(d,1) 
            tw_vhc(1,1) = demandstarttime(d,1)-Tbegin - t0;
            t0 = demandstarttime(d,1);
        else
            tw_vhc(1,1) = 0;
            t0 = t0 + Tbegin;
        end
        Bi(1,1)=t0;
        for j = 1:k-1
            u = solution(1,j);
            v = solution(1,j+1);
            t0 = t0 + timematrix(v,u);
            if v>2*demand
                tw_vhc(j+1,1)=0;
                continue
            end
            if v<=size(demandtime,1)
                if t0 <= demandtime(v,1)
                    tw_vhc(j+1,1) = demandtime(v,1)-t0;
                    t0 = demandtime(v,1);
                else
                    tw_vhc(j+1,1)=0;
                end
            end
            Bi(j+1,1)=t0;
        end
        T_vehicle=t0+vhcdemandtimematrix(i,solution(1,k))-Tbegin; %��������ʱ��
         %���������������������������������������������������������������������������ؿ�������
        [ CapacityChain ] = CapacityPunishment(i,solution,demand,vhccapacity);
        q=CapacityChain;
         %���������������������������������������������������������������������������ȴ�ʱ�䡢�ڳ��˿͵ȴ�ʱ�䡢����ʱ��ɱ�       
        Tw_vhc =sum(tw_vhc,1); %�����ȴ�ʱ��
        tw_pas(1,1)=0;
        for m=2:k
            tw_pas(m,1)=q(m-1,1).*tw_vhc(m,1);
        end
        Tw_pas = sum(tw_pas,1);
        c_vehiclewaiting = cwk(i,1)*Tw_vhc; %�ܳ����ȴ�ʱ��ɱ�
        c_patientonboardwaiting = cpk*Tw_pas;%���ڳ��˿͵ȴ�ʱ��ɱ�
        c_traveltime = ctk(i,1)*T_vehicle;%�ܳ�������ʱ��ɱ�
        c_fixedcost = fixedcost(i,1);
%         L = vhcdemanddistancematrix(i,solution(1,1))+vhcdemanddistancematrix(i,solution(1,k));
         %�����������������������������������������������������������������������������о���ɱ�����
%         for m=2:k                       
%             L = L+distancematrix(solution(1,m-1),solution(1,m));
%         end
%         c_traveldistance = fixedcost(i,1)+ck(i,1)*(L-L0(i,1)); 
         %�����������������������������������������������������������������������˿�����ָ�����
        quality_1 = 0;                  
        quality_2 = 0;
        quality_3 = 0;
        for j=1:k
            if solution(1,j)<=demand
                quality_1 = quality_1+sqrt(((demandstarttime(solution(1,j),1)+demandstarttime(solution(1,j),2))/2-Bi(j,1))^2);
                for m=(j+1):k
                    if (solution(1,j)+demand)== solution(1,m)
                        quality_3 = quality_3+sqrt(((Bi(m,1)-Bi(j,1))-timematrix(solution(1,j),solution(1,m)))^2);
                    end
                end
            end
            if solution(1,j)>demand&&solution(1,j)<=2*demand
                quality_2 = quality_2+sqrt((Bi(j,1)-demandendtime(solution(1,j)-demand,1))^2);
            end   
        end
        %�������������������������������������������������������������������������ͷ���������(ʱ�䴰�ͷ�����ؿ����ͷ����˿��ڳ�ʱ��ͷ�)
        c_twpunishment = Tw_vhc;
        c_tipunishment = 0;
        c_cpunishment = 0;  
        for m=1:k
            if q(m,1)>vhccapacity(i,1)
                c_cpunishment=c_cpunishment+q(m,1)-vhccapacity(i,1);
            end
            if solution(1,m)<=demand
                for n=(m+1):k
                    if (solution(1,m)+demand)== solution(1,n)
                        if (Bi(n,1)-Bi(m,1))>Ti(solution(1,m),solution(1,n))
                            c_tipunishment=c_tipunishment+(Bi(n,1)-Bi(m,1))-Ti(solution(1,m),solution(1,n));
                        end
                    end
                end
            end 
        end    
    end
    C_twpunishment = C_twpunishment + c_twpunishment;
    C_tipunishment = C_tipunishment + c_tipunishment;
    C_cpunishment = C_cpunishment + c_cpunishment;
    C_punishment = C_punishment + C_twpunishment + C_tipunishment + C_cpunishment;
    
    
    C_fixedcost = C_fixedcost + c_fixedcost;
    C_traveltime = C_traveltime + c_traveltime;
    C_patientonboardwaiting = C_patientonboardwaiting + c_patientonboardwaiting;
    C_vehiclewaiting = C_vehiclewaiting + c_vehiclewaiting;
    C = alpha_1*C_fixedcost + alpha_2*C_traveltime + alpha_3*C_patientonboardwaiting + alpha_4*C_vehiclewaiting;%��Ȩ�ܳɱ�

    Quality_1 = Quality_1 + c_1*quality_1;
    Quality_2 = Quality_2 + c_2*quality_2;
    Quality_3 = Quality_3 + c_3*quality_3;
    Quality = beta_1*Quality_1 + beta_2*Quality_2 + beta_3*Quality_3;%��Ȩ�ܷ�������
    Cost = Cost + C +  Quality + alpha*C_twpunishment + beta*C_tipunishment + gamma*C_cpunishment;
end

objective =[Cost C+Quality C C_fixedcost C_traveltime C_patientonboardwaiting C_vehiclewaiting Quality Quality_1 Quality_2 Quality_3];

    


