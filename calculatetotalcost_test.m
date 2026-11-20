function [Cost,objective] = calculatetotalcost_test(solutioncell,demand,vhccapacity,demandstarttime,demandendtime,vhcstarttime,timematrix,vhcdemandtimematrix,fixedcost,cwk,ctk,op,tsop)
% Repository weighted objective, with unit-passenger loads.
% Defaults match the included snapshot; transfer partner waiting is excluded.
if nargin < 12, op = 2; end
if nargin < 13, tsop = 3; end
if ~iscell(solutioncell) || (~isempty(solutioncell) && ~isvector(solutioncell))
    error('Shuttle:SolutionShape','Routes must be a cell vector with one cell per vehicle.');
end
solutioncell = solutioncell(:);
M = numel(solutioncell);

%------------------------- Weight coefficients for each cost component
alpha_1 = 0.15;   % cost coefficient
alpha_2 = 0.25;
alpha_3 = 0.3;
alpha_4 = 0.3;
beta_1 = 0.4;
beta_2 = 0.4;
beta_3 = 0.2;

%------------------------- Cost initialization
Cost = 0;  % objective function value

C_fixedcost = 0; % total fixed cost
C_traveltime = 0;     % total operating time cost
C_patientonboardwaiting = 0;  % total cost for passenger onboard waiting time
C_vehiclewaiting = 0;   % total vehicle waiting time cost
C = 0;     % weighted total cost

Quality_1 = 0;   % total service quality 1 - in terms of time
Quality_2 = 0;   % total service quality 2
Quality_3 = 0;   % total service quality 3
Quality = 0;     % weighted total service quality

% c = 100; % inconvenience index cost
c_1 = 10; % inconvenience index 1 cost
c_2 = 8; % inconvenience index 2 cost
c_3 = 2; % inconvenience index 3 cost
cpk = 3; % cost per unit of passenger onboard waiting time

for i = 1:M    % loop over vehicles
    solution = solutioncell{i,1};
    if ~isnumeric(solution) || ~isreal(solution) || ...
            (~isempty(solution) && ~isvector(solution)) || ...
            any(~isfinite(solution(:))) || any(solution(:) < 1) || ...
            any(solution(:) ~= fix(solution(:))) || ...
            any(solution(:) > size(timematrix,1)) || ...
            any(solution(:) > size(vhcdemandtimematrix,2))
        error('Shuttle:RouteStructure','Route %d contains an invalid node vector.',i);
    end
    solution = solution(:)';
    [CapacityChain,validStructure] = CapacityPunishment(i,solution,demand,vhccapacity);
    if ~validStructure
        error('Shuttle:RouteStructure','Route %d has inconsistent pickup, delivery or transfer order.',i);
    end
    k = size(solution,2); % calculate the number of demand points in each vehicle route chain
    if k == 0
        c_fixedcost = 0;
        c_traveltime = 0;
        c_patientonboardwaiting = 0;
        c_vehiclewaiting = 0;
        quality_1 = 0;
        quality_2 = 0;
        quality_3 = 0;
    else
        [~,Bi,~,tw_vhc,returnTime] = RouteSchedule(solution,i,vhcstarttime, ...
            inf(M,2),demandstarttime,demandendtime,timematrix, ...
            vhcdemandtimematrix,demand,op,tsop);
        Bi = Bi(:);
        tw_vhc = tw_vhc(:);
        T_vehicle = returnTime - vhcstarttime(i,1);
        %--------------------- Calculation of vehicle capacity (passenger load)
        q = CapacityChain';
        %--------------------- Vehicle waiting time, passenger onboard waiting time, and operating time costs
        Tw_vhc = sum(tw_vhc,1); % vehicle waiting time
        tw_pas = zeros(k,1);
        for m = 2:k
            tw_pas(m,1) = q(m-1,1) * tw_vhc(m,1);
        end
        Tw_pas = sum(tw_pas,1);
        c_vehiclewaiting = cwk(i,1) * Tw_vhc; % total vehicle waiting time cost
        c_patientonboardwaiting = cpk * Tw_pas; % total passenger onboard waiting time cost
        c_traveltime = ctk(i,1) * T_vehicle; % total vehicle operating time cost
        c_fixedcost = fixedcost(i,1);
        quality_1 = 0;
        quality_2 = 0;
        quality_3 = 0;
        for j = 1:k
            if solution(1,j) <= demand
                quality_1 = quality_1 + sqrt(((demandstarttime(solution(1,j),1) + demandstarttime(solution(1,j),2)) / 2 - Bi(j,1))^2);
                for m = (j+1):k
                    if (solution(1,j) + demand) == solution(1,m)
                        quality_3 = quality_3 + sqrt(((Bi(m,1) - Bi(j,1)) - timematrix(solution(1,j),solution(1,m)))^2);
                    end
                end
            end
            if solution(1,j) > demand && solution(1,j) <= 2*demand
                quality_2 = quality_2 + sqrt((Bi(j,1) - demandendtime(solution(1,j)-demand,1))^2);
            end
        end
    end

    C_fixedcost = C_fixedcost + c_fixedcost;
    C_traveltime = C_traveltime + c_traveltime;
    C_patientonboardwaiting = C_patientonboardwaiting + c_patientonboardwaiting;
    C_vehiclewaiting = C_vehiclewaiting + c_vehiclewaiting;
    C = alpha_1 * C_fixedcost + alpha_2 * C_traveltime + alpha_3 * C_patientonboardwaiting + alpha_4 * C_vehiclewaiting; % weighted total cost
    Quality_1 = Quality_1 + c_1 * quality_1;
    Quality_2 = Quality_2 + c_2 * quality_2;
    Quality_3 = Quality_3 + c_3 * quality_3;
    Quality = beta_1 * Quality_1 + beta_2 * Quality_2 + beta_3 * Quality_3; % weighted total service quality
end
Cost = (C + Quality) / 1000;
objective = [Cost, C + Quality, C, C_fixedcost, C_traveltime, C_patientonboardwaiting, C_vehiclewaiting, Quality, Quality_1, Quality_2, Quality_3];
