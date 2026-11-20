function report = ValidateSolution(routes, data, expectedRequests)
%VALIDATESOLUTION Check request coverage, route loads and route time bounds.
% Transfer connections use independent vehicle clocks.
if nargin < 3, expectedRequests = data.expectedRequests; end
n = data.demand; m = data.vhcnum;
if ~isnumeric(expectedRequests) || ~isreal(expectedRequests) || ...
        (~isempty(expectedRequests) && ~isvector(expectedRequests)) || ...
        any(~isfinite(expectedRequests(:))) || ...
        any(expectedRequests(:) ~= fix(expectedRequests(:))) || ...
        any(expectedRequests(:) < 1 | expectedRequests(:) > n) || ...
        numel(unique(expectedRequests)) ~= numel(expectedRequests)
    error('Shuttle:RequestSet','Expected request IDs must be unique integers from 1 to demand.');
end
issues = {}; pickupVehicle = zeros(1,n); deliveryVehicle = zeros(1,n);
pickupPosition = zeros(1,n); deliveryPosition = zeros(1,n);
transferNode = zeros(m,1); transferPosition = zeros(m,1);
arrivals = cell(m,1); departures = cell(m,1); returnTimes = zeros(m,1);
hasTransfers = false;
if ~iscell(routes) || numel(routes) ~= m
    error('Shuttle:SolutionShape','Expected one route cell per vehicle.');
end
for v = 1:m
    route = routes{v};
    if ~isnumeric(route) || ~isreal(route) || (~isempty(route) && ~isvector(route))
        issues{end+1} = sprintf('Vehicle %d route must be a real numeric vector.',v); %#ok<AGROW>
        continue
    end
    route = route(:)';
    if any(~isfinite(route) | route < 1 | route ~= fix(route) | route > size(data.timematrix,1)) || ...
            any(route > 2*n & ~ismember(route,data.TS))
        issues{end+1} = sprintf('Vehicle %d has an invalid node ID.',v); %#ok<AGROW>
        continue
    end
    transfers = find(route > 2*n);
    if ~isempty(transfers)
        hasTransfers = true;
        if numel(transfers) ~= 1
            issues{end+1} = sprintf('Vehicle %d has more than one transfer visit.',v); %#ok<AGROW>
        else
            transferNode(v) = route(transfers); transferPosition(v) = transfers;
        end
    end
    for p = 1:numel(route)
        node = route(p);
        if node <= n
            if pickupVehicle(node) ~= 0
                issues{end+1} = sprintf('Request %d is picked up more than once.',node); %#ok<AGROW>
            end
            pickupVehicle(node) = v; pickupPosition(node) = p;
        elseif node <= 2*n
            r = node-n;
            if deliveryVehicle(r) ~= 0
                issues{end+1} = sprintf('Request %d is delivered more than once.',r); %#ok<AGROW>
            end
            deliveryVehicle(r) = v; deliveryPosition(r) = p;
        end
    end
    if ~CapacityCheck(v,route,n,data.vhccapacity)
        issues{end+1} = sprintf('Vehicle %d violates load or pickup/delivery ordering.',v); %#ok<AGROW>
    end
    [ok,arrivals{v},departures{v},~,returnTimes(v)] = RouteSchedule(route,v, ...
        data.vhcstarttime,data.vhcendtime,data.demandstarttime,data.demandendtime, ...
        data.timematrix,data.vhcdemandtimematrix,n,data.op,data.tsop);
    if ~ok
        issues{end+1} = sprintf('Vehicle %d violates a service or depot time window.',v); %#ok<AGROW>
    end
    if ~isempty(route) && ~isempty(data.depotendtime)
        closing = data.depotendtime(data.depotendtime(:,1) == data.vhcdepot(v),2);
        if numel(closing) ~= 1 || returnTimes(v) > closing
            issues{end+1} = sprintf('Vehicle %d returns after its depot closes.',v); %#ok<AGROW>
        end
    end
    if ~CalculatingTotalTime(v,route,n,data.vhccapacity,data.demandstarttime, ...
            data.demandendtime,data.vhcstarttime,data.timematrix, ...
            data.vhcdemandtimematrix,data.fixedcost,data.cwk,data.ctk,data.TravelTimeMax)
        issues{end+1} = sprintf('Vehicle %d exceeds the driving-time limit.',v); %#ok<AGROW>
    end
end
served = find(pickupVehicle > 0 & deliveryVehicle > 0);
if ~isequal(find(pickupVehicle > 0),sort(expectedRequests(:)')) || ...
        ~isequal(find(deliveryVehicle > 0),sort(expectedRequests(:)'))
    issues{end+1} = 'Pickup and delivery coverage differs from the initial served request set.';
end
for r = served
    a = pickupVehicle(r); b = deliveryVehicle(r);
    if a == b
        if pickupPosition(r) >= deliveryPosition(r)
            issues{end+1} = sprintf('Request %d is delivered before pickup.',r); %#ok<AGROW>
        end
    elseif transferNode(a) == 0 || transferNode(a) ~= transferNode(b) || ...
            pickupPosition(r) >= transferPosition(a) || deliveryPosition(r) <= transferPosition(b)
        issues{end+1} = sprintf('Request %d has no consistent transfer connection.',r); %#ok<AGROW>
    end
end
report = struct();
report.routeConstraintsSatisfied = isempty(issues);
report.hasTransfers = hasTransfers;
report.transferSynchronizationChecked = ~hasTransfers;
report.feasible = isempty(issues) && ~hasTransfers;
report.scope = 'Unit requests, fixed return depots, initial served request set';
if hasTransfers
    report.scope = [report.scope '; independent vehicle clocks at transfers'];
end
report.issues = issues;
report.servedRequests = served;
report.unservedRequests = setdiff(1:n,served);
report.activeVehicles = sum(~cellfun('isempty',routes));
report.arrivals = arrivals; report.departures = departures; report.returnTimes = returnTimes;
end
