function sol = run(obj,G)
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

if nargin < 2
    G = route(obj);
end

options = obj.options;

if length(obj.steps) < numnodes(G)
    % add dummy steps
    obj.steps(end+1:numnodes(G)) = newstep(obj,'dummy',[]);
end

nodes = (1:numnodes(G));

iter = 0;
sidx = 1;

active = double(nodes == sidx);

sol = struct;

varnames = getvariables(obj.prob);
% subnames = getvariables(obj.prob,'subvars');

symbols = struct;
assigns = struct;

% get symbolic variables
for var=varnames
    symbols.(var{:}) = getvariable(obj.prob,var);
    assigns.(var{:}) = NaN;
    
    sol.(var{:}) = [];
end

sol.obj = Inf;
% prepare array of solutions
solution(options.Niter) = sol;

while iter <= options.Niter
    % current step
    step = obj.steps(sidx);
    
    % state-machine
    switch step.type
        case 'init'
            %% initialize iteration
            iter = iter + 1;
            
            if iter == 1
                % initialize solution variables
                for var=step.varout
                    [~,sol.(var{:})] = hasinitial(obj.prob,var{:});
                end
            end
            
        case {'convex' 'bisect'}
            %% main optimization step
            sosc = newconstraints(obj.prob.sosf,obj.prob.x);
            
            for var=step.lvar
                [sosc,assigns.(var{:})] = instantiate(obj.prob,sosc,var);
            end
            for var=step.varin
                assigns.(var{:}) = sol.(var{:});
            end
            for var=step.subnames
                [sosc,assigns.(var{:})] = evaluate(obj.prob,sosc,var,symbols,assigns);
            end
            
            if strcmp(step.type,'bisect')
                % prepare bisection
                [sosc,ovar] = instantiate(obj.prob,sosc,step.ovar);
                
                assigns.(step.ovar{:}) = ovar;
                assigns.(step.ovar{:}) = bisos.subs(step.obj,symbols,assigns);
            end
            
            step.obj = bisos.subs(step.obj,symbols,assigns);
                
            sosc = constraint(obj.prob,sosc,step.cidx,symbols,assigns);
                
            % solve optimization
            stepsol = runstep(obj,step,sosc,options.sosoptions);
            
            if ~stepsol.feas
                printf(options,'warning','Step %s infeasible at iteration %d.\n', G.Nodes.Name{sidx}, iter);
                break;
            end
            
            % assign outputs
            for var=step.varout
                sol.(var{:}) = subs(assigns.(var{:}), stepsol);
            end
            
        case 'obj'
            %% set objective
            for var=step.varin
                assigns.(var{:}) = sol.(var{:});
            end
            
            sol.obj = evalobj(obj.prob,symbols,assigns);
            
            printf(options,'step','Objective = %g at iteration %d.\n', sol.obj, iter);
            
            %TODO: save solution to file
            solution(iter) = sol;
            
        otherwise
            % nothing to do
    end
    
    %% compute next step
    % mark current step as visited
    active(sidx) = 2;
    
    % get successors of visited nodes
    next = arrayfun(@(a) successors(G,a), nodes(active>1), 'UniformOutput', false);
    
    % iterate over candidate successors
    for idx = vertcat(next{:})'
        % predecessors
        cond = predecessors(G,idx);
        
        % check if all predecessors have been visited
        if all(active(cond) > 1)
            % mark successor as active
            active(idx) = 1;
        end
    end
    
    % iterate over visited nodes
    for idx = nodes(active>1)
        % check if all successors are active
        if all(active(next{nodes(active>1)==idx}) > 0)
            % toggle visited nodes
            active(idx) = 0;
        end
    end
    
    nidx = find(active==1,1);
    
    printf(options,'debug','Step %d successful, next step %d.\n', sidx, nidx);
    
    sidx = nidx;
end
            
% find iteration with minimal objective
[~,imin] = min([solution.obj]);

% set output
sol = solution(imin);

end

