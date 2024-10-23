function [obandvar,varr,Cost,objective] = Generate_Costs(solutioncell,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk)
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

%���������������������������������������ɱ���ʼ��
Cost = 0;  %Ŀ�꺯��ֵ

C_fixedcost = 0; %�̶ܹ��ɱ�
C_traveltime = 0; %������ʱ��ɱ�
C_p_onboardwaiting = 0;  %�ܳ˿��ڳ�ʱ��ɱ�
C_vehiclewaiting = 0;   %�ܳ����ȴ�ʱ��ɱ�
C = 0; %��Ȩ�ܳɱ�

Quality_1 = 0;   %�ܷ�������1������ʱ��Ϊ��λ
Quality_2 = 0;   %�ܷ�������2
Quality_3 = 0;   %�ܷ�������3
Quality = 0; %��Ȩ�ܷ�������


% c = 100; %����ݶ�ָ��ɱ�
c_1 = 10; %����ݶ�ָ��1�ɱ�
c_2 = 8; %����ݶ�ָ��2�ɱ�
c_3 = 2; %����ݶ�ָ��3�ɱ�
cpk = 3; %��λ�ڳ��˿͵ȴ�ʱ��ɱ�
Ti =timematrix.*3; %���˿��ڳ�ʱ��
tw_vhc_sum=[];
tw_pas_sum=[];
qua1_sum=[];
qua2_sum=[];
qua3_sum=[];
for i = 1:M%������ѭ��
solution = solutioncell{i,1};
k = size(solution,2);%����ÿ�����������ж��������
if k == 0
c_fixedcost = 0;
c_traveltime = 0;
c_p_onboardwaiting = 0;
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
tw_vhc(1,1) = 0;
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
q=CapacityChain';
%���������������������������������������������������������������������������ȴ�ʱ�䡢�ڳ��˿͵ȴ�ʱ�䡢����ʱ��ɱ�
Tw_vhc =sum(tw_vhc,1); %�����ȴ�ʱ��
tw_vhc_sum=[tw_vhc_sum;Tw_vhc];
tw_pas(1,1)=0;
for m=2:k
tw_pas(m,1)=q(m-1,1).*tw_vhc(m,1);
end
tw_pas_sum=[tw_pas_sum;tw_pas];
Tw_pas = sum(tw_pas,1);
c_vehiclewaiting = Tw_vhc; %�ܳ����ȴ�ʱ��ɱ�
c_p_onboardwaiting = Tw_pas;%���ڳ��˿͵ȴ�ʱ��ɱ�
c_traveltime = T_vehicle;%�ܳ�������ʱ��ɱ�
c_fixedcost = fixedcost(i,1);
% L = vhcdemanddistancematrix(i,solution(1,1))+vhcdemanddistancematrix(i,solution(1,k));
%�����������������������������������������������������������������������������о���ɱ�����
% for m=2:k
% L = L+distancematrix(solution(1,m-1),solution(1,m));
% end
% c_traveldistance = fixedcost(i,1)+ck(i,1)*(L-L0(i,1));
%�����������������������������������������������������������������������˿�����ָ�����
quality_1 = 0;
quality_2 = 0;
quality_3 = 0;
for j=1:k
if solution(1,j)<=demand
quality_1 = quality_1+sqrt(((demandstarttime(solution(1,j),1)+demandstarttime(solution(1,j),2))/2-Bi(j,1))^2);
qua1_sum=[qua1_sum,sqrt(((demandstarttime(solution(1,j),1)+demandstarttime(solution(1,j),2))/2-Bi(j,1))^2)];
for m=(j+1):k
if (solution(1,j)+demand)== solution(1,m)
quality_3 = quality_3+sqrt(((Bi(m,1)-Bi(j,1))-timematrix(solution(1,j),solution(1,m)))^2);
qua3_sum=[qua3_sum,sqrt(((Bi(m,1)-Bi(j,1))-timematrix(solution(1,j),solution(1,m)))^2)];
end
end
end
if solution(1,j)>demand&&solution(1,j)<=2*demand
quality_2 = quality_2+sqrt((Bi(j,1)-demandendtime(solution(1,j)-demand,1))^2);
qua2_sum=[qua2_sum,sqrt((Bi(j,1)-demandendtime(solution(1,j)-demand,1))^2)];
end
end
%�������������������������������������������������������������������������ͷ���������(ʱ�䴰�ͷ�����ؿ����ͷ����˿��ڳ�ʱ��ͷ�)
end

C_fixedcost = C_fixedcost + c_fixedcost;
C_traveltime = C_traveltime + c_traveltime;
C_p_onboardwaiting = C_p_onboardwaiting + c_p_onboardwaiting;
C_vehiclewaiting = C_vehiclewaiting + c_vehiclewaiting;
C = alpha_1*C_fixedcost + alpha_2*C_traveltime + alpha_3*C_p_onboardwaiting + alpha_4*C_vehiclewaiting;%��Ȩ�ܳɱ�
Quality_1 = Quality_1 + quality_1;
Quality_2 = Quality_2 + quality_2;
Quality_3 = Quality_3 + quality_3;
Quality = beta_1*Quality_1 + beta_2*Quality_2 + beta_3*Quality_3;%��Ȩ�ܷ�������
Cost = Cost + C +  Quality;

end
passengernum=0;
vehiclenum=0;
C_total=C_fixedcost+C_traveltime;
for i=1:M
solutionnnn=solutioncell{i,1};
if isempty(solutionnnn)
continue
else
vehiclenum=vehiclenum+1;
end
for j=1:size(solutionnnn,2)
if solutionnnn(1,j)<=demand
passengernum=passengernum+1;
end
end
end
Cost=Cost/1000;
tw_vhc_sum=tw_vhc_sum';
tw_pas_sum=tw_pas_sum';
var_tw_vhc_sum=std2(tw_vhc_sum);
var_tw_pas_sum=std2(tw_pas_sum);
var_qua1_sum=std2(qua1_sum);
var_qua2_sum=std2(qua2_sum);
var_qua3_sum=std2(qua3_sum);
varr=[var_tw_pas_sum var_tw_vhc_sum var_qua1_sum var_qua2_sum var_qua3_sum];
objective =[C_total C_fixedcost C_total/passengernum C_fixedcost/passengernum C_traveltime/passengernum C_p_onboardwaiting/passengernum C_vehiclewaiting/vehiclenum Quality_1/passengernum Quality_2/passengernum Quality_3/passengernum vehiclenum passengernum];
b=roundn(C_vehiclewaiting/vehiclenum,-2);
a=roundn(var_tw_vhc_sum,-2);
obandvar=[{[num2str(roundn(C_p_onboardwaiting/passengernum,-2)) '��' num2str(roundn(var_tw_pas_sum,-2))]},{[num2str(b) '��' num2str(a)]},{[num2str(roundn(Quality_1/passengernum,-2)) '��' num2str(roundn(var_qua1_sum,-2))]},{[num2str(roundn(Quality_2/passengernum,-2)) '��' num2str(roundn(var_qua2_sum,-2))]},{[num2str(roundn(Quality_3/passengernum,-2)) '��' num2str(roundn(var_qua3_sum,-2))]}];




