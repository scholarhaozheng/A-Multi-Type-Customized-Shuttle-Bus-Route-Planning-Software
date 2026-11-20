function result = MDVRPTW(source, options)
%MDVRPTW Run ALNS/Tabu route operators from a supplied initial solution.
% MDVRPTW(make_demo_instance(),struct('MaxIterations',5)) runs a small case.
% MDVRPTW([],struct('MaxIterations',0)) evaluates the supplied MAT snapshot.
if nargin < 1, source = []; end
if nargin < 2, options = struct(); end
if ~isstruct(options) || ~isscalar(options)
    error('Shuttle:Options','Options must be a scalar struct.');
end
data = LoadShuttleInstance(source);
defaults = struct('MaxIterations',10,'Neighbors',3,'Seed',7, ...
    'EnableTransfers',false,'Verbose',false,'OutputDir','');
names = fieldnames(options);
for k = 1:numel(names)
    if ~isfield(defaults,names{k}), error('Shuttle:UnknownOption','Unknown option: %s',names{k}); end
    defaults.(names{k}) = options.(names{k});
end
options = defaults;
validateattributes(options.MaxIterations,{'numeric'},{'scalar','real','finite','integer','nonnegative'});
validateattributes(options.Neighbors,{'numeric'},{'scalar','real','finite','integer','positive'});
validateattributes(options.Seed,{'numeric'},{'scalar','real','finite','integer','nonnegative','<=',2^32-1});
validateattributes(options.EnableTransfers,{'logical','numeric'},{'scalar','real','finite','binary'});
validateattributes(options.Verbose,{'logical','numeric'},{'scalar','real','finite','binary'});
if isstring(options.OutputDir) && isscalar(options.OutputDir)
    options.OutputDir = char(options.OutputDir);
end
if ~ischar(options.OutputDir) || (~isempty(options.OutputDir) && ~isrow(options.OutputDir))
    error('Shuttle:OutputDir','OutputDir must be a character row or a scalar string.');
end
validateattributes(data.lambda,{'numeric'},{'scalar','integer','positive'});
validateattributes(data.tabulength,{'numeric'},{'scalar','integer','positive'});
validateattributes(data.r,{'numeric'},{'scalar','>=',0,'<=',1});
oldRng = rng; cleanupRng = onCleanup(@() rng(oldRng)); %#ok<NASGU>
rng(options.Seed,'twister'); started = tic;
initial = data.inisolution1;
initialValidation = ValidateSolution(initial,data);
if options.MaxIterations > 0 && ~initialValidation.feasible
    error('Shuttle:InitialFeasibility', ...
        ['Initial routes are not certified feasible. Use MaxIterations=0 to inspect ' ...
         'validation.issues; run_demo supplies a feasible small instance.']);
end
cost = @(s) calculatetotalcost_test(s,data.demand,data.vhccapacity, ...
    data.demandstarttime,data.demandendtime,data.vhcstarttime,data.timematrix, ...
    data.vhcdemandtimematrix,data.fixedcost,data.cwk,data.ctk,data.op,data.tsop);
[initialCost,initialObjective] = cost(initial);
current = initial; best = initial; currentCost = initialCost; bestCost = initialCost;
relations = zeros(data.vhcnum,2); bestRelations = relations;
tabuList = cell(0,1);
noTransferHistory = cell(max(1,options.MaxIterations),1);
relationHistory = cell(max(1,options.MaxIterations),1);
history = zeros(options.MaxIterations+1,3); history(1,:) = [0 initialCost initialCost];
selectedOperators = zeros(options.MaxIterations,2);
destroyChoices = zeros(options.MaxIterations,options.Neighbors);
repairChoices = zeros(options.MaxIterations,options.Neighbors);
% Select the implemented random and greedy paired-insertion operators.
destroyWeights = 0.1*ones(1,5); repairWeights = 0.1*ones(1,2);
destroyScores = zeros(1,5); repairScores = zeros(1,2);
destroyUses = zeros(1,5); repairUses = zeros(1,2);
transferNodes = data.TS;
if ~options.EnableTransfers, transferNodes = []; end
if options.EnableTransfers && ~isempty(transferNodes)
    endings = data.depotendtime;
    if ~isnumeric(endings) || size(endings,2) ~= 2 || any(~isfinite(endings(:))) || ...
            ~all(ismember(data.vhcdepot,endings(:,1))) || ...
            numel(unique(endings(:,1))) ~= size(endings,1)
        error('Shuttle:DepotWindows','Transfer search requires unique [depotID closingTime] rows.');
    end
end
for iteration = 1:options.MaxIterations
    candidates = cell(options.Neighbors,1); noTransfer = cell(options.Neighbors,1);
    candidateRelations = cell(options.Neighbors,1);
    candidateKeys = cell(options.Neighbors,1); reverseKeys = cell(options.Neighbors,1);
    costs = inf(options.Neighbors,1);
    chosen = zeros(options.Neighbors,2);
    for j = 1:options.Neighbors
        d = GeneratingOperatorsChoice(iteration,data.lambda,1,destroyWeights);
        r = GeneratingOperatorsChoice(iteration,data.lambda,2,repairWeights);
        chosen(j,:) = [d r];
        destroyChoices(iteration,j) = d; repairChoices(iteration,j) = r;
        destroyUses(d) = destroyUses(d)+1; repairUses(r) = repairUses(r)+1;
        if options.Verbose
            [relTs,relNo,move,sNo,sTs,unusedCost] = neighbor(current,noTransferHistory,relations,data,transferNodes,d,r,iteration,relationHistory);
        else
            evalc('[relTs,relNo,move,sNo,sTs,unusedCost] = neighbor(current,noTransferHistory,relations,data,transferNodes,d,r,iteration,relationHistory);');
        end
        noTransfer{j} = sNo;
        vNo = ValidateSolution(sNo,data); cNo = inf;
        if vNo.feasible, cNo = cost(sNo); end
        cTs = inf;
        if options.EnableTransfers && ~isempty(sTs)
            vTs = ValidateSolution(sTs,data);
            if vTs.routeConstraintsSatisfied, cTs = cost(sTs); end
        end
        if cTs < cNo
            candidates{j} = sTs; candidateRelations{j} = relTs; costs(j) = cTs;
        else
            candidates{j} = sNo; candidateRelations{j} = relNo; costs(j) = cNo;
        end
        if isequal(candidates{j},current), costs(j) = inf; end
        if isfinite(costs(j))
            [candidateKeys{j},reverseKeys{j}] = AssignmentMoveKey(current,candidates{j},data.demand);
        end
    end
    tabuFlags = false(options.Neighbors,1);
    for j = 1:options.Neighbors
        if ~isempty(tabuList) && ~isempty(candidateKeys{j})
            tabuFlags(j) = any(strcmp(tabuList,candidateKeys{j}));
        end
    end
    selected = SelectALNSNeighbor(costs,tabuFlags,bestCost);
    if selected > 0
        previousCost = currentCost;
        current = candidates{selected}; currentCost = costs(selected);
        relations = candidateRelations{selected};
        noTransferHistory{iteration} = noTransfer{selected};
        selectedOperators(iteration,:) = chosen(selected,:); reward = 0;
        if currentCost < bestCost
            best = current; bestCost = currentCost; bestRelations = relations;
            reward = data.alpha1;
        elseif currentCost < previousCost
            reward = data.alpha2;
        elseif currentCost > previousCost
            reward = data.alpha3;
        end
        d = chosen(selected,1); r = chosen(selected,2);
        destroyScores(d) = destroyScores(d)+reward;
        repairScores(r) = repairScores(r)+reward;
        if ~isempty(reverseKeys{selected})
            tabuList{end+1,1} = reverseKeys{selected}; %#ok<AGROW>
        end
    else
        if ~isempty(tabuList), tabuList(1,:) = []; end
        if iteration > 1, noTransferHistory{iteration} = noTransferHistory{iteration-1};
        else, noTransferHistory{iteration} = initial; end
    end
    if size(tabuList,1) > data.tabulength, tabuList = tabuList(end-data.tabulength+1:end,:); end
    relationHistory{iteration} = relations;
    history(iteration+1,:) = [iteration currentCost bestCost];
    if mod(iteration,data.lambda) == 0
        destroyWeights = updateWeights(destroyWeights,destroyScores,destroyUses,data.r);
        repairWeights = updateWeights(repairWeights,repairScores,repairUses,data.r);
        destroyScores(:) = 0; repairScores(:) = 0;
        destroyUses(:) = 0; repairUses(:) = 0;
    end
    if options.Verbose, fprintf('Iteration %d: current %.8f, best %.8f\n',iteration,currentCost,bestCost); end
end
[unused,objective] = cost(best); %#ok<ASGLU>
runtimeName = 'MATLAB';
if exist('OCTAVE_VERSION','builtin'), runtimeName = 'GNU Octave'; end
result = struct('initialCost',initialCost,'bestCost',bestCost, ...
    'initialObjective',initialObjective, ...
    'bestSolution',{best},'currentSolution',{current},'history',history, ...
    'objective',objective,'selectedOperators',selectedOperators, ...
    'destroyChoices',destroyChoices,'repairChoices',repairChoices, ...
    'destroyWeights',destroyWeights,'repairWeights',repairWeights, ...
    'transferRelationships',bestRelations,'tabuMemory',{tabuList},'options',options, ...
    'initialValidation',initialValidation,'validation',ValidateSolution(best,data), ...
    'elapsedSeconds',toc(started),'runtime',version,'runtimeName',runtimeName, ...
    'unservedRequests',data.unservedRequests);
if options.EnableTransfers, result.mode = 'Experimental transfer search; independent route costs';
else, result.mode = 'No-transfer search on the initial served request set'; end
if ~isempty(options.OutputDir)
    if exist(options.OutputDir,'dir') ~= 7, mkdir(options.OutputDir); end
    save(fullfile(options.OutputDir,'result.mat'),'result','-v7');
    dlmwrite(fullfile(options.OutputDir,'history.csv'),history,'precision','%.15g');
    fid = fopen(fullfile(options.OutputDir,'routes.csv'),'w');
    if fid < 0, error('Shuttle:Output','Cannot open routes.csv.'); end
    cleanupFile = onCleanup(@() fclose(fid)); %#ok<NASGU>
    fprintf(fid,'vehicle,position,node\n');
    for v = 1:numel(best)
        for p = 1:numel(best{v}), fprintf(fid,'%d,%d,%d\n',v,p,best{v}(p)); end
    end
end
end

function weights = updateWeights(weights,scores,uses,reaction)
weights = (1-reaction)*weights;
used = uses > 0;
weights(used) = weights(used)+reaction*scores(used)./uses(used);
if ~any(weights > 0), weights(:) = 0.1; end
end

function [relTs,relNo,move,sNo,sTs,cTs] = neighbor(current,noHistory,relations,d,ts,des,rep,iteration,relHistory)
[relTs,relNo,move,sNo,sTs,cTs] = DestroyandRepair_swap_2opt_func0803_edit_rep_1( ...
    current,noHistory,relations,d.demand,d.vhcstarttime,d.vhcendtime, ...
    d.demandstarttime,d.demandendtime,d.timematrix,d.vhcdemandtimematrix,ts, ...
    d.depotendtime,d.vhccapacity,d.fixedcost,d.cwk,d.ctk,d.vhcdepot,des,rep, ...
    d.TravelTimeMax,d.op,d.tsop,d.SetTsMax,d.EachOptionMax,iteration,relHistory);
end
