function checks = support_regressions()
%SUPPORT_REGRESSIONS Paired repair, transfer insertion and bounded-neighbor checks.
checks = 0;
n = 3;
t = ones(7)-eye(7);
windows = repmat([0 100],n,1);
start = [0 0]; finish = [0 100]; depotTimes = ones(1,7);
capacity = 3; fixed = 10; waitingCost = 1; runningCost = 1;

% Two outgoing passengers must both disappear from the sender's delivery list.
[ok,route] = InsertdeliverypointALNS0711([1 2 3 4 5 6],7,3,[],[1 2], ...
    n,0,0,1,start,finish,windows,windows,t,depotTimes,capacity, ...
    fixed,waitingCost,runningCost,100,2,3);
assert(ok && isequal(route,[1 2 3 7 6])); checks = checks+1;
[load,valid] = CapacityPunishment(1,route,n,capacity);
assert(valid && isequal(load,[1 2 3 1 0])); checks = checks+1;

% Feasible time windows cannot override an exceeded driving-time limit.
[ok,route] = InsertdeliverypointALNS0711([1 2 3 4 5 6],7,3,[],[1 2], ...
    n,0,0,1,start,finish,windows,windows,t,depotTimes,capacity, ...
    fixed,waitingCost,runningCost,1,2,3);
assert(~ok && isempty(route)); checks = checks+1;

% Both repair operators must handle a sequence of insertions into an empty route.
repairs = {@RepairOperator1_0803,@RepairOperator2_0426};
for k = 1:numel(repairs)
    [ok,route,positions] = repairs{k}([],2,[1 2],1,start,finish, ...
        windows,windows,t,depotTimes,n,{[]},capacity,fixed, ...
        waitingCost,runningCost,100,2,3);
    assert(ok && isequal(sort(route),[1 2 4 5]) && ...
        isequal(route(positions),[1 2]) && CapacityCheck(1,route,n,capacity));
    checks = checks+1;
    [ok,unchanged,positions] = repairs{k}(route,0,[],1,start,finish, ...
        windows,windows,t,depotTimes,n,{route},capacity,fixed, ...
        waitingCost,runningCost,100,2,3);
    assert(ok && isequal(unchanged,route) && isempty(positions)); checks = checks+1;
end

[ok,route] = BackToNoTs(1,{[1 2 3 7]},cell(1,1),zeros(1,2),n, ...
    start,finish,windows,windows,t,depotTimes,7,[7 100],capacity, ...
    fixed,waitingCost,runningCost,7,1,1,100,2,3,4,4,1,[1 2 3]);
assert(ok && isequal(sort(route),1:6) && CapacityCheck(1,route,n,capacity));
checks = checks+1;

d = LoadShuttleInstance(make_demo_instance());
d.demandstarttime = repmat([0 10000],d.demand,1);
d.demandendtime = d.demandstarttime;
d.vhcendtime = repmat([0 10000],d.vhcnum,1);
d.depotendtime(:,2) = 10000;
d.vhccapacity(:) = d.demand;
d.TravelTimeMax = 10000;
oldRng = rng; cleanupRng = onCleanup(@() rng(oldRng)); %#ok<NASGU>
rng(19,'twister');
for destroy = 1:5
    for repair = 1:2
        evalc('[move,route] = mutate(d,d.inisolution1,destroy,repair);');
        report = ValidateSolution(route,d);
        assert(any(move) && report.feasible && isequal(sort([route{:}]),1:12));
        checks = checks+1;
    end
end

% One active route has no pair to exchange; return promptly without a fake move.
single = {[1 7]; []; []};
[move,route] = mutate(d,single,1,1);
assert(~any(move) && isequal(route,single)); checks = checks+1;

% Fourteen onboard requests imply 2^14-1 subset pairs, beyond the budget.
largeN = 14;
routeA = [1:7,15:21]; routeB = [8:14,22:28];
largeWindows = repmat([0 10000],largeN,1);
limited = false;
try
    TsBestSolutionALNS0711({routeA;routeB},[7 7 7 14 29 0 100], ...
        routeA,routeB,29,largeN,0,0,1,0,0,2,zeros(2,2), ...
        repmat([0 10000],2,1),largeWindows,largeWindows,zeros(29), ...
        zeros(2,29),[14;14],[10;10],[1;1],[1;1],10000,2,3,4,4);
catch failure
    limited = strcmp(failure.identifier,'Shuttle:TransferEnumerationLimit');
end
assert(limited); checks = checks+1;

% Tabu memory must match the actual inverse of an exchange, in either order.
before = {[1 3];[2 4]}; after = {[2 4];[1 3]};
[forward,reverse] = AssignmentMoveKey(before,after,2);
[backward,opposite] = AssignmentMoveKey(after,before,2);
assert(strcmp(forward,'1,1,1,2,2;2,2,2,1,1;') && ...
    strcmp(reverse,backward) && strcmp(forward,opposite)); checks = checks+1;

% Segment keys contain every changed request, including non-leading members.
before = {[1 2 5 6];[3 4 7 8]}; after = flipud(before);
[full,reverse] = AssignmentMoveKey(before,after,4);
partial = {[3 2 7 6];[1 4 5 8]};
[part,~] = AssignmentMoveKey(before,partial,4);
[backward,~] = AssignmentMoveKey(after,before,4);
assert(sum(full==';') == 4 && ~strcmp(full,part) && strcmp(reverse,backward));
checks = checks+1;

% Moving only a delivery endpoint is still a transfer assignment change.
[forward,reverse] = AssignmentMoveKey({[1 3];[2 4]}, {[1 5];[2 5 3 4]},2);
assert(strcmp(forward,'1,1,1,1,2;') && strcmp(reverse,'1,1,2,1,1;'));
checks = checks+1;
[forward,reverse] = AssignmentMoveKey({[1 2 3 4];[]},{[2 1 4 3];[]},2);
assert(isempty(forward) && isempty(reverse)); checks = checks+1;

% Cell-vector orientation must not discard routes from the fleet objective.
d = make_demo_instance();
score = @(routes) calculatetotalcost_test(routes,d.demand,d.vhccapacity, ...
    d.demandstarttime,d.demandendtime,d.vhcstarttime,d.timematrix, ...
    d.vhcdemandtimematrix,d.fixedcost,d.cwk,d.ctk,d.op,d.tsop);
assert(abs(score(d.inisolution1)-score(d.inisolution1')) < 1e-12);
checks = checks+1;
bad = d.inisolution1; bad{1} = [1 1 7]; rejected = false;
try
    score(bad);
catch failure
    rejected = strcmp(failure.identifier,'Shuttle:RouteStructure');
end
assert(rejected); checks = checks+1;

badOptions = {struct('MaxIterations',inf),struct('Neighbors',1i), ...
    struct('Seed',2^32),struct('OutputDir',{{'bad'}}), ...
    struct('OutputDir',['a';'b'])};
for k = 1:numel(badOptions)
    rejected = false;
    try
        MDVRPTW(d,badOptions{k});
    catch
        rejected = true;
    end
    assert(rejected); checks = checks+1;
end

% With one active route, all sampled exchanges are no-ops and remain unaccepted.
one = d; one.inisolution1 = {[1 7]; []; []};
one.inireject1 = (2:d.demand)';
one = LoadShuttleInstance(one);
result = MDVRPTW(one,struct('MaxIterations',3,'Neighbors',2));
assert(isequal(result.bestSolution,one.inisolution1) && ...
    ~any(result.selectedOperators(:)) && isempty(result.tabuMemory));
checks = checks+1;

% A failed one-way transfer must not prune a feasible balanced exchange.
xy = [1 0;8 8;8 4;3 8;5 0;4 4;7 7;8 2;1 9];
t = zeros(9);
for u = 1:9
    for v = 1:9, t(u,v) = norm(xy(u,:)-xy(v,:)); end
end
a = [1 2 5 6]; b = [3 4 7 8]; windows = repmat([0 1000],4,1);
[routes,value] = TsBestSolutionALNS0711({a;b},[2 2 2 4 9 0 1000], ...
    a,b,9,4,0,0,1,0,0,2,zeros(2,2),repmat([0 1000],2,1), ...
    windows,windows,t,ones(2,9),[2;2],[10;10],[1;1],[1;3],1000,2,3,4,20);
assert(isequal(routes,{[1 2 9 8 7];[3 4 9 6 5]}) && ...
    abs(value-8.351951046659) < 1e-11); checks = checks+1;
end

function [move,sNo] = mutate(d,solution,destroy,repair)
[~,~,move,sNo] = DestroyandRepair_swap_2opt_func0803_edit_rep_1( ...
    solution,cell(1,1),zeros(d.vhcnum,2),d.demand,d.vhcstarttime,d.vhcendtime, ...
    d.demandstarttime,d.demandendtime,d.timematrix,d.vhcdemandtimematrix,[], ...
    d.depotendtime,d.vhccapacity,d.fixedcost,d.cwk,d.ctk,d.vhcdepot, ...
    destroy,repair,d.TravelTimeMax,d.op,d.tsop,d.SetTsMax,d.EachOptionMax,1,cell(1,1));
end
