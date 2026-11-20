function [forward,reverse] = AssignmentMoveKey(before,after,demand)
%ASSIGNMENTMOVEKEY Canonical full-request vehicle transitions and their inverse.
% Each changed request contributes pickup and delivery vehicle IDs. Route
% positions and transfer-station choices are outside these tabu attributes.
oldAssignments = assignments(before,demand);
newAssignments = assignments(after,demand);
changed = find(any(oldAssignments ~= newAssignments,2));
if isempty(changed)
    forward = '';
    reverse = '';
    return
end
transitions = [changed,oldAssignments(changed,:),newAssignments(changed,:)];
forward = sprintf('%d,%d,%d,%d,%d;',transitions');
reverse = sprintf('%d,%d,%d,%d,%d;',transitions(:,[1 4 5 2 3])');
end

function owners = assignments(routes,demand)
owners = zeros(demand,2);
for vehicle = 1:numel(routes)
    route = routes{vehicle};
    for node = route(:)'
        if node > 2*demand, continue; end
        request = mod(node-1,demand)+1;
        endpoint = 1+(node>demand);
        if owners(request,endpoint) ~= 0
            error('Shuttle:MoveIdentity','A request endpoint occurs more than once.');
        end
        owners(request,endpoint) = vehicle;
    end
end
end
