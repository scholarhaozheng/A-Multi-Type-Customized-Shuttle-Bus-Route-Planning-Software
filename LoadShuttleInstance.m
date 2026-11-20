function data = LoadShuttleInstance(source)
%LOADSHUTTLEINSTANCE Load and validate shuttle routing inputs.
if nargin == 0 || (isnumeric(source) && isempty(source)) || (ischar(source) && isempty(source))
    source = fullfile(fileparts(mfilename('fullpath')), 'initial0805_concentrate.mat');
end
if isstruct(source)
    if ~isscalar(source), error('Shuttle:InputShape','Instance must be a scalar struct.'); end
    data = source;
else
    if ~(ischar(source) && isrow(source)) && ~(isa(source,'string') && isscalar(source))
        error('Shuttle:InputType','Input must be a scalar structure or MAT-file path.');
    end
    source = char(source);
    if exist(source, 'file') ~= 2
        error('Shuttle:MissingInput', 'MAT file does not exist: %s', source);
    end
    data = load(source);
    if numel(fieldnames(data)) == 1 && isfield(data,'data')
        if ~isstruct(data.data) || ~isscalar(data.data)
            error('Shuttle:InputShape','The MAT variable data must be a scalar instance structure.');
        end
        data = data.data;
    end
end
required = {'demand','vhcnum','inisolution1','demandstarttime','demandendtime', ...
    'vhcstarttime','vhcendtime','timematrix','vhcdemandtimematrix', ...
    'vhccapacity','fixedcost','cwk','ctk','vhcdepot'};
for k = 1:numel(required)
    if ~isfield(data, required{k})
        error('Shuttle:MissingField', 'Missing instance field: %s', required{k});
    end
end
validateattributes(data.demand, {'numeric'}, {'scalar','real','finite','integer','positive'});
validateattributes(data.vhcnum, {'numeric'}, {'scalar','real','finite','integer','positive'});
n = data.demand; m = data.vhcnum;
if ~iscell(data.inisolution1) || numel(data.inisolution1) ~= m
    error('Shuttle:InputShape', 'inisolution1 must have one cell per vehicle.');
end
data.inisolution1 = reshape(data.inisolution1, [], 1);
for k = 1:m
    route = data.inisolution1{k};
    if ~isempty(route)
        validateattributes(route, {'numeric'}, {'vector','real','integer','positive','finite'});
    end
    data.inisolution1{k} = reshape(route, 1, []);
end
names = {'demandstarttime','demandendtime','vhcstarttime','vhcendtime'};
rows = [n n m m];
for k = 1:numel(names)
    a = data.(names{k});
    if ~isnumeric(a) || ~isreal(a) || ~isequal(size(a), [rows(k),2]) || ...
            any(~isfinite(a(:))) || any(a(:,1) > a(:,2))
        error('Shuttle:InputShape', '%s must contain finite [earliest latest] rows.', names{k});
    end
end
names = {'vhccapacity','fixedcost','cwk','ctk','vhcdepot'};
for k = 1:numel(names)
    a = data.(names{k});
    validateattributes(a, {'numeric'}, {'vector','real','numel',m,'finite','nonnegative'});
    data.(names{k}) = a(:);
end
validateattributes(data.vhccapacity, {'numeric'}, {'integer','positive'});
t = data.timematrix;
if ~isnumeric(t) || ~isreal(t) || ~ismatrix(t) || size(t,1) ~= size(t,2) || size(t,1) <= 2*n || ...
        any(~isfinite(t(:))) || any(t(:) < 0)
    error('Shuttle:InputShape', 'timematrix must be square, finite and nonnegative.');
end
validateattributes(data.vhcdepot, {'numeric'}, {'integer','>',2*n,'<=',size(t,1)});
if ~isnumeric(data.vhcdemandtimematrix) || ~isreal(data.vhcdemandtimematrix) || ...
        ~isequal(size(data.vhcdemandtimematrix), [m size(t,1)]) || ...
        any(~isfinite(data.vhcdemandtimematrix(:))) || any(data.vhcdemandtimematrix(:) < 0)
    error('Shuttle:InputShape', 'vhcdemandtimematrix must be vehicles by nodes.');
end
% Operators use this matrix for both depot legs.
depotLegs = t(data.vhcdepot,:);
returnLegs = t(:,data.vhcdepot)';
if any(abs(depotLegs(:)-data.vhcdemandtimematrix(:)) > 1e-8) || ...
        any(abs(depotLegs(:)-returnLegs(:)) > 1e-8)
    error('Shuttle:DepotTravel', 'Depot travel must agree with timematrix in both directions.');
end
defaults = struct('op',2,'tsop',3,'TravelTimeMax',480,'SetTsMax',16, ...
    'EachOptionMax',8,'tabulength',30,'lambda',100,'alpha1',33,'alpha2',9, ...
    'alpha3',13,'r',0.1,'TS',[],'depotendtime',[]);
names = fieldnames(defaults);
for k = 1:numel(names)
    if ~isfield(data,names{k}), data.(names{k}) = defaults.(names{k}); end
end
validateattributes(data.TS, {'numeric'}, {'real','integer','finite','>',2*n,'<=',size(t,1)});
if ~isempty(data.TS) && ~isvector(data.TS)
    error('Shuttle:InputShape','TS must be a vector of transfer node IDs.');
end
data.TS = reshape(data.TS,1,[]);
if numel(unique(data.TS)) ~= numel(data.TS) || any(ismember(data.TS,data.vhcdepot))
    error('Shuttle:NodeID','Transfer node IDs must be unique and distinct from depots.');
end
if isfield(data,'tsNum') && (~isnumeric(data.tsNum) || ~isscalar(data.tsNum) || ...
        ~isreal(data.tsNum) || data.tsNum ~= numel(data.TS))
    error('Shuttle:InputShape','tsNum must equal the number of transfer node IDs.');
end
data.tsNum = numel(data.TS);
depotIDs = setdiff(2*n+1:size(t,1),data.TS);
if isfield(data,'depotNum') && (~isnumeric(data.depotNum) || ~isscalar(data.depotNum) || ...
        ~isreal(data.depotNum) || data.depotNum ~= numel(depotIDs))
    error('Shuttle:InputShape','depotNum must equal the number of depot nodes.');
end
data.depotNum = numel(depotIDs);
endings = data.depotendtime;
if ~isnumeric(endings) || ~isreal(endings) || (~isempty(endings) && ...
        (~ismatrix(endings) || size(endings,2) ~= 2 || any(~isfinite(endings(:))) || ...
         any(~ismember(endings(:,1),depotIDs)) || ...
         numel(unique(endings(:,1))) ~= size(endings,1) || ...
         ~all(ismember(data.vhcdepot,endings(:,1)))))
    error('Shuttle:DepotWindows','depotendtime must list unique [depotID closingTime] rows for every vehicle depot.');
end
controls = {'op','tsop','alpha1','alpha2','alpha3'};
for k = 1:numel(controls)
    validateattributes(data.(controls{k}),{'numeric'},{'scalar','real','finite','nonnegative'});
end
controls = {'SetTsMax','EachOptionMax','tabulength','lambda'};
for k = 1:numel(controls)
    validateattributes(data.(controls{k}),{'numeric'},{'scalar','real','finite','integer','positive'});
end
validateattributes(data.TravelTimeMax,{'numeric'},{'scalar','real','finite','positive'});
validateattributes(data.r,{'numeric'},{'scalar','real','finite','>=',0,'<=',1});
allNodes = [data.inisolution1{:}];
if any(allNodes > size(t,1)) || any(allNodes > 2*n & ~ismember(allNodes,data.TS))
    error('Shuttle:NodeID', 'Routes may contain request nodes and declared transfer nodes only.');
end
data.expectedRequests = unique(allNodes(allNodes <= n));
data.unservedRequests = setdiff(1:n,data.expectedRequests);
if isfield(data,'inireject1')
    rejected = data.inireject1;
    if ~isnumeric(rejected) || ~isreal(rejected) || ...
            (~isempty(rejected) && ~isvector(rejected)) || ...
            any(~isfinite(rejected(:))) || any(rejected(:) ~= fix(rejected(:))) || ...
            any(rejected(:) < 1 | rejected(:) > n) || ...
            ~isequal(sort(rejected(:)),sort(data.unservedRequests(:)))
        error('Shuttle:RejectedRequests', 'inireject1 must contain exactly the unserved request IDs.');
    end
end
data.inireject1 = data.unservedRequests(:);
data.demandtime = [data.demandstarttime;data.demandendtime];
end
