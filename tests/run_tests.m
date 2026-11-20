function run_tests()
%RUN_TESTS Regression checks for route feasibility, objective and selection.
root = fileparts(fileparts(mfilename('fullpath')));
oldPath = path;
cleanup = onCleanup(@() path(oldPath)); %#ok<NASGU>
addpath(root);
d = make_demo_instance();
checks = 0;

[q,valid] = CapacityPunishment(1,[1 2 7 8],6,d.vhccapacity);
assert(valid && isequal(q,[1 2 1 0])); checks = checks+1;
assert(CapacityCheck(1,[1 2 7 8],6,[1;3;4]) == 0); checks = checks+1;
assert(CapacityCheck(1,[7 1],6,d.vhccapacity) == 0); checks = checks+1;
assert(CapacityCheck(1,[1 7 8 2],6,d.vhccapacity) == 0); checks = checks+1;
[q,valid] = CapacityPunishment(1,[1 2 13 8],6,d.vhccapacity);
assert(valid && isequal(q,[1 2 1 0])); checks = checks+1;
[q,valid] = CapacityPunishment(1,[13 7],6,d.vhccapacity);
assert(valid && isequal(q,[1 0])); checks = checks+1;
assert(CapacityCheck(1,[1 13 14 7],6,d.vhccapacity) == 0); checks = checks+1;
assert(CapacityCheck(1,[],6,d.vhccapacity) == 1); checks = checks+1;

whole = cost(d.inisolution1,d);
parts = 0;
for i = 1:d.vhcnum
    isolated = cell(d.vhcnum,1);
    isolated{i} = d.inisolution1{i};
    parts = parts + cost(isolated,d);
end
assert(abs(whole-parts) < 1e-10); checks = checks+1;
order = [3 1 2];
p = d;
vehicleFields = {'vhccapacity','vhcstarttime','vhcdemandtimematrix','fixedcost','cwk','ctk'};
for i = 1:numel(vehicleFields)
    value = d.(vehicleFields{i});
    p.(vehicleFields{i}) = value(order,:);
end
assert(abs(whole-cost(d.inisolution1(order),p)) < 1e-10); checks = checks+1;
assert(cost(cell(d.vhcnum,1),d) == 0); checks = checks+1;

% Directed travel distinguishes t(1,2)=3 from t(2,1)=19.
t = [0 3;19 0];
[ok,a,b,~,back] = RouteSchedule([1 2],1,[0 0],[0 100],[0 100],[0 100], ...
    t,[2 5],1,2,3);
assert(ok && isequal(a,[2 7]) && isequal(b,[4 9]) && back == 14); checks = checks+1;
assert(judgement_op([1 2],1,[0 0],[0 13],[0 100],[0 100],t,[2 5],1,2,3) == 0);
checks = checks+1; % Final service duration must be counted before depot return.
assert(judgement_op([1 2],1,[0 0],[0 14],[0 100],[0 100],t,[2 5],1,2,3) == 1);
checks = checks+1;
[ok,a,b] = RouteSchedule([1 2],1,[0 0],[0 100],[10 100],[0 100],t,[2 5],1,2,3);
assert(ok && isequal(a,[10 15]) && isequal(b,[12 17])); checks = checks+1;
directedCost = calculatetotalcost_test({[1 2]},1,1,[0 100],[0 100], ...
    [0 0],t,[2 5],10,2,1,2,3);
assert(abs(directedCost-0.2202) < 1e-12); checks = checks+1;

checks = checks + support_regressions();
checks = checks + input_regressions();
checks = checks + saved_instance_regressions(root);

assert(SelectALNSNeighbor([12;11],[true;true],10) == 0); checks = checks+1;
assert(SelectALNSNeighbor([9;11],[true;true],10) == 1); checks = checks+1;
assert(SelectALNSNeighbor([12;11],[false;true],10) == 1); checks = checks+1;
assert(SelectALNSNeighbor([12;9],[false;true],10) == 2); checks = checks+1;

opts = struct('MaxIterations',2,'Neighbors',3,'Seed',7, ...
    'EnableTransfers',false,'Verbose',false,'OutputDir','');
r = MDVRPTW(d,opts);
assert(r.bestCost <= r.initialCost + 1e-10); checks = checks+1;
seen = sort([r.bestSolution{:}]);
assert(isequal(seen,1:2*d.demand)); checks = checks+1;
again = MDVRPTW(d,opts);
assert(r.bestCost == again.bestCost && isequal(r.bestSolution,again.bestSolution));
checks = checks+1;
% One adaptation segment: reward the selected operator and divide by its use count.
d.lambda = 1;
d.r = 0.1;
opts.MaxIterations = 1;
adapted = MDVRPTW(d,opts);
reward = 0;
if adapted.history(2,2) < adapted.initialCost
    reward = d.alpha1;
elseif adapted.history(2,2) > adapted.initialCost
    reward = d.alpha3;
end
expectedDestroy = (1-d.r)*0.1*ones(1,5);
expectedRepair = (1-d.r)*0.1*ones(1,2);
selected = adapted.selectedOperators(1,:);
if all(selected > 0)
    expectedDestroy(selected(1)) = expectedDestroy(selected(1)) + ...
        d.r*reward/sum(adapted.destroyChoices(:) == selected(1));
    expectedRepair(selected(2)) = expectedRepair(selected(2)) + ...
        d.r*reward/sum(adapted.repairChoices(:) == selected(2));
end
assert(all(abs(adapted.destroyWeights-expectedDestroy) < 1e-12)); checks = checks+1;
assert(all(abs(adapted.repairWeights-expectedRepair) < 1e-12)); checks = checks+1;
fprintf('Passed %d regression checks.\n',checks);
end

function checks = input_regressions()
% Malformed inputs must not produce apparently feasible route evaluations.
d = make_demo_instance();
checks = 0;
bad = repmat(d,0,1);
assert(rejects(@() LoadShuttleInstance(bad))); checks = checks+1;
bad = d; bad.vhcdepot(1) = 1;
assert(rejects(@() LoadShuttleInstance(bad))); checks = checks+1;
bad = d; bad.vhccapacity(1) = 1.5;
assert(rejects(@() LoadShuttleInstance(bad))); checks = checks+1;
bad = d; bad.op = -1;
assert(rejects(@() LoadShuttleInstance(bad))); checks = checks+1;
bad = d; bad.timematrix = cat(3,d.timematrix,d.timematrix);
assert(rejects(@() LoadShuttleInstance(bad))); checks = checks+1;
bad = d; bad.tsNum = d.tsNum+1;
assert(rejects(@() LoadShuttleInstance(bad))); checks = checks+1;
bad = d; bad.TS = [13 13];
assert(rejects(@() LoadShuttleInstance(bad))); checks = checks+1;
bad = d; bad.depotendtime(1,1) = 1;
assert(rejects(@() LoadShuttleInstance(bad))); checks = checks+1;
bad = d; bad.inireject1 = [1 1];
assert(rejects(@() LoadShuttleInstance(bad))); checks = checks+1;

d = LoadShuttleInstance(d);
assert(rejects(@() ValidateSolution(d.inisolution1,d,[1 1]))); checks = checks+1;
routes = d.inisolution1; routes{1} = [1 2 7];
v = ValidateSolution(routes,d);
assert(~v.feasible && ~v.routeConstraintsSatisfied); checks = checks+1;
routes = d.inisolution1; routes{1} = [1 1 7 8];
v = ValidateSolution(routes,d);
assert(~v.feasible && ~v.routeConstraintsSatisfied); checks = checks+1;
routes = d.inisolution1; routes{1}(1) = NaN;
v = ValidateSolution(routes,d);
assert(~v.feasible && ~v.routeConstraintsSatisfied); checks = checks+1;
d.depotendtime(:,2) = 5;
v = ValidateSolution(d.inisolution1,d);
assert(~v.feasible && any(cellfun(@(s) ~isempty(strfind(s,'depot closes')),v.issues)));
checks = checks+1;
end

function yes = rejects(action)
yes = false;
try
    action();
catch
    yes = true;
end
end

function checks = saved_instance_regressions(root)
% The example's exported instance and a flat MAT workspace are reusable inputs.
outputRoot = fullfile(root,'results');
if exist(outputRoot,'dir') ~= 7, mkdir(outputRoot); end
folder = tempname(outputRoot);
mkdir(folder);
cleanupFiles = onCleanup(@() remove_mat_fixtures(folder)); %#ok<NASGU>
data = make_demo_instance();
options = struct('MaxIterations',1,'OutputDir','');
save(fullfile(folder,'wrapped.mat'),'data','-v7');
wrapped = MDVRPTW(fullfile(folder,'wrapped.mat'),options);
assert(wrapped.validation.feasible); checks = 1;
save(fullfile(folder,'flat.mat'),'-struct','data','-v7');
flat = MDVRPTW(fullfile(folder,'flat.mat'),options);
assert(flat.bestCost == wrapped.bestCost && isequal(flat.bestSolution,wrapped.bestSolution));
checks = checks+1;

marker = 1;
save(fullfile(folder,'mixed.mat'),'data','marker','-v7');
assert(rejects(@() LoadShuttleInstance(fullfile(folder,'mixed.mat')))); checks = checks+1;
instance = data;
save(fullfile(folder,'other.mat'),'instance','-v7');
assert(rejects(@() LoadShuttleInstance(fullfile(folder,'other.mat')))); checks = checks+1;
data = repmat(data,1,2);
save(fullfile(folder,'malformed.mat'),'data','-v7');
assert(rejects(@() LoadShuttleInstance(fullfile(folder,'malformed.mat')))); checks = checks+1;
end

function remove_mat_fixtures(folder)
names = {'wrapped.mat','flat.mat','mixed.mat','other.mat','malformed.mat'};
for k = 1:numel(names)
    file = fullfile(folder,names{k});
    if exist(file,'file') == 2
        if exist('OCTAVE_VERSION','builtin')
            [status,message] = unlink(file);
            assert(status == 0,message);
        else
            delete(file);
        end
    end
end
if exist(folder,'dir') == 7, rmdir(folder); end
end

function value = cost(routes,d)
value = calculatetotalcost_test(routes,d.demand,d.vhccapacity,d.demandstarttime, ...
    d.demandendtime,d.vhcstarttime,d.timematrix,d.vhcdemandtimematrix, ...
    d.fixedcost,d.cwk,d.ctk,d.op,d.tsop);
end
