function result = run_demo(options)
%RUN_DEMO Run ALNS-Tabu search on a six-request synthetic instance.
%   result = run_demo();
%   result = run_demo(struct('MaxIterations',20,'Seed',7));
%   Results are written to results/demo unless OutputDir is supplied.
root = fileparts(mfilename('fullpath'));
oldPath = path;
cleanup = onCleanup(@() path(oldPath)); %#ok<NASGU>
addpath(root);
if nargin < 1
    options = struct();
end
if ~isstruct(options) || ~isscalar(options)
    error('Shuttle:Options','Options must be a scalar struct.');
end
defaults = struct('MaxIterations',5,'Neighbors',3,'Seed',7, ...
    'EnableTransfers',false,'Verbose',false,'OutputDir',fullfile(root,'results','demo'));
names = fieldnames(defaults);
for k = 1:numel(names)
    if ~isfield(options,names{k})
        options.(names{k}) = defaults.(names{k});
    end
end
data = make_demo_instance();
result = MDVRPTW(data,options);
if ~isempty(options.OutputDir)
    save(fullfile(options.OutputDir,'instance.mat'),'data','-v7');
end
fprintf('Synthetic example: %d requests, %d vehicles, %d depots.\n', ...
    data.demand,data.vhcnum,data.depotNum);
fprintf('Initial cost: %.9f; best cost: %.9f\n',result.initialCost,result.bestCost);
for k = 1:numel(result.bestSolution)
    fprintf('Vehicle %d: %s\n',k,mat2str(result.bestSolution{k}));
end
end
