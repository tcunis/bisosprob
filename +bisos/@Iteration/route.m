function G = route(obj)
% Compute a routing for this iteration scheme.
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:tcunis@umich.edu>
% * Created:    2020-03-30
% * Changed:    2020-03-31
%
%%

varnames = getvariables(obj.prob);
stepidxs = false(size(obj.steps));

G = digraph;

% initial step
stepidxs(1) = 1;

G = addnode(G,length(obj.steps));

% variables with initial values
initvar = obj.getstep(1).varout;

% available variables
solved = ismember(varnames,initvar);
% updated variables
update = false(size(varnames));

active = stepidxs;

while any(~stepidxs) %TODO: this leads to an infinite loop if a step is never visited
    activate = active;
    % iterate active steps
    for idx = find(active)
        % explore sucessor steps
        for next = successors(obj.stepgraph,idx)'
            % check successor step 
            if stepidxs(next)
                % already visited, nothing to do
            elseif all(~ismember(varnames,obj.getstep(next).varin) | solved)
                % all input variables are solved
                G = addedge(G,find(active),next);
                % toggle active and visited steps
                activate(next) = 1;
                activate(active) = 0;
                % visited steps
                stepidxs = stepidxs | activate;
            end
        end
    end
    varout = cellfun(@(s) s.varout, obj.steps(activate), 'UniformOutput', false);
    varout = [varout{:}];
    % updated & solved variables
    solved = solved | ismember(varnames,varout);
    update = update | ismember(varnames,varout);

    if isequal(active,activate)
        % no advances
        error('Cannot close iteration after %d steps.', sum(stepidxs));
    end
    % active steps next iteration
    active = activate;
end

if sum(active) > 1
    % add dummy node for last step
    last = length(obj.steps)+1;
    G = addedge(G,find(active),last);
else
    last = find(active);
end
    
if ~all(update)
    unchgd = varnames(~update);
    warning('Variable ''%s'' seems unchanged after one iteration.', unchgd{1});
end

% next iteration
G = addedge(G,last,1);

% add node names for visualization
G = graph(obj,G);
