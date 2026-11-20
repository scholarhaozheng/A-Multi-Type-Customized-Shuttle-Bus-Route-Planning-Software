function index = SelectALNSNeighbor(costs, tabuFlags, bestCost)
%SELECTALNSNEIGHBOR Lowest finite admissible cost; zero means no legal move.
costs = costs(:); tabuFlags = logical(tabuFlags(:));
if numel(costs) ~= numel(tabuFlags)
    error('Shuttle:NeighborShape', 'Costs and tabu flags must have equal length.');
end
admissible = isfinite(costs) & (~tabuFlags | costs < bestCost);
indices = find(admissible);
index = 0;
if ~isempty(indices)
    [~,k] = min(costs(indices));
    index = indices(k);
end
end
