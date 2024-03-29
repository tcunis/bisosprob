function [sol,info] = run(obj,G)
% Run the specified iteration scheme.
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:tcunis@umich.edu>
% * Created:    2020-03-30
% * Changed:    2020-03-30
%
%%

if nargin > 1 
    % nothing to do
else
    % follow steps by user-defined order
    N = length(obj.steps);
    G = digraph(circshift(eye(N),-1));
end

options = preparelog(obj.options);

% add dummy steps if necessary
obj = complete(obj,G);

nodes = (1:numnodes(G));

info.iter = 0;
sidx = 1;

tokens = arrayfun(@(a) -length(predecessors(G,a)), nodes);
tokens(sidx) = 0;

sol = struct;

varnames = getvariables(obj.prob);
% subnames = getvariables(obj.prob,'subvars');

symbols = struct;
assigns = struct;

% get symbolic variables
for var=varnames
    symbols.(var{:}) = getsymbol(obj.prob,var);
    assigns.(var{:}) = NaN;
    
    sol.(var{:}) = [];
end

sol.obj = Inf;
% prepare array of step information
stepinfo(options.Niter) = cell(1);
info.steps = table;

while info.iter <= options.Niter
    % current step
    step = obj.getstep(sidx);
    
    % state-machine
    [sol,info,stop] = run(step,obj.prob,info,sol,symbols,struct,options);
    
    if stop
        % Abort iteration
        break;
    end

    stepinfo(info.iter) = {info.steps};
    
    %% compute next step
    % mark current node as visited
    tokens(sidx) = -length(predecessors(G,sidx));
    
    % get successors of current node
    next = successors(G,sidx);
    
    % distribute tokens to successors
    tokens(next) = tokens(next) + 1;
    
    nidx = find(tokens==0,1);
    
    printf(options,'debug','Step %d successful, next step %d.\n', sidx, nidx);
    
    sidx = nidx;
end
            
if info.iter > 1
    info.iter = info.iter - 1;
end
stepinfo = vertcat(stepinfo{1:info.iter});


% set output
sol = stepinfo.obj(end).sol;

% evaluate final steps
fstop = cellfun(@(step) run_final(step,obj.prob,info,sol,options), obj.steps);

stop = max([stop fstop]);
if stop >= 2
    % solution erroneous
    sol = [];
end

info.steps = stepinfo;

finishlog(options,stop);

end

