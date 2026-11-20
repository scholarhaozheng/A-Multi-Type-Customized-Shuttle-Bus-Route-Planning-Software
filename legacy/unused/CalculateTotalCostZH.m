function [Cost] = CalculateTotalCostZH(solutioncell,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk)
M = size(solutioncell,1);
demandtime=[demandstarttime;demandendtime];

%——————————————————各成本项权重系数
alpha_1 = 0.15;   %成本系数
alpha_2 = 0.25;
alpha_3 = 0.3;
alpha_4 = 0.3;
beta_1 = 0.4;
beta_2 = 0.4;
beta_3 = 0.2;
alpha = 1000;     %惩罚因子
beta = 1000;
gamma = 1000;

%———————————————————成本初始化
Cost = 0;  %目标函数值

C_fixedcost = 0; %总固定成本
C_traveltime = 0;     %总运行时间成本
C_patientonboardwaiting = 0;  %总乘客在车时间成本
C_vehiclewaiting = 0;   %总车辆等待时间成本
C = 0;     %加权总成本

Quality_1 = 0;   %总服务质量1——以时间为单位
Quality_2 = 0;   %总服务质量2
Quality_3 = 0;   %总服务质量3
Quality = 0;     %加权总服务质量

C_twpunishment = 0; %总时间窗惩罚
C_tipunishment = 0; %总车辆运行时间惩罚
C_cpunishment = 0;  %总额定载客量惩罚
C_punishment = 0;   %总惩罚


% c = 100; %不便捷度指标成本
c_1 = 10; %不便捷度指标1成本
c_2 = 8; %不便捷度指标2成本
c_3 = 2; %不便捷度指标3成本
cpk = 3; %单位在车乘客等待时间成本
Ti =timematrix.*3; %最大乘客在车时间

for i = 1:M    %车辆数循环
    solution = solutioncell{i,1};
    k = size(solution,2);%计算每条车次链共有多少需求点
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
        tw_vhc = zeros(k,1);   %车辆等待时间
        tw_pas = zeros(k,1);   
        q =zeros(k,1);
       
         %———————————————————————————————————车辆等待时间计算
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
        T_vehicle=t0+vhcdemandtimematrix(i,solution(1,k))-Tbegin; %车辆运行时间
         %———————————————————————————————————车辆载客量计算
        [ CapacityChain ] = CapacityPunishment(i,solution,demand,vhccapacity);
        q=CapacityChain;
         %———————————————————————————————————车辆等待时间、在车乘客等待时间、运行时间成本       
        Tw_vhc =sum(tw_vhc,1); %车辆等待时间
        tw_pas(1,1)=0;
        for m=2:k
            tw_pas(m,1)=q(m-1,1).*tw_vhc(m,1);
        end
        Tw_pas = sum(tw_pas,1);
        c_vehiclewaiting = cwk(i,1)*Tw_vhc; %总车辆等待时间成本
        c_patientonboardwaiting = cpk*Tw_pas;%总在车乘客等待时间成本
        c_traveltime = ctk(i,1)*T_vehicle;%总车辆运行时间成本
        c_fixedcost = fixedcost(i,1);
%         L = vhcdemanddistancematrix(i,solution(1,1))+vhcdemanddistancematrix(i,solution(1,k));
         %———————————————————————————————————车辆运行距离成本计算
%         for m=2:k                       
%             L = L+distancematrix(solution(1,m-1),solution(1,m));
%         end
%         c_traveldistance = fixedcost(i,1)+ck(i,1)*(L-L0(i,1)); 
         %———————————————————————————————————乘客评价指标计算
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
        %————————————————————————————————————惩罚函数计算(时间窗惩罚、额定载客量惩罚、乘客在车时间惩罚)
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
    C = alpha_1*C_fixedcost + alpha_2*C_traveltime + alpha_3*C_patientonboardwaiting + alpha_4*C_vehiclewaiting;%加权总成本

    Quality_1 = Quality_1 + c_1*quality_1;
    Quality_2 = Quality_2 + c_2*quality_2;
    Quality_3 = Quality_3 + c_3*quality_3;
    Quality = beta_1*Quality_1 + beta_2*Quality_2 + beta_3*Quality_3;%加权总服务质量
    Cost = Cost + C +  Quality + alpha*C_twpunishment + beta*C_tipunishment + gamma*C_cpunishment;
end

objective =[Cost C+Quality C C_fixedcost C_traveltime C_patientonboardwaiting C_vehiclewaiting Quality Quality_1 Quality_2 Quality_3];

    


