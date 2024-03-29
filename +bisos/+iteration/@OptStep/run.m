function [sol,info,stop] = run(step,prob,info,sol,symbols,assigns,options)
% Run optimization step.

sosc = newconstraints(prob.sosf,prob.x);

subprob = [];
            
for var=step.lvar
    [sosc,assigns.(var{:})] = instantiate(prob,sosc,var);
end
for var=step.varin
    assigns.(var{:}) = sol.(var{:});
end
for var=step.subnames
%     if isfield(assigns,var), continue; end % nothing to do
    [sosc,assigns.(var{:})] = evaluate(prob,sosc,var,symbols,assigns);
end

% prepare objective
[sosc,assigns] = prepare(step,prob,sosc,symbols,assigns);

objective = bisos.subs(step.objective,symbols,assigns,step.variables);

sosc = constraint(prob,sosc,step.cidx,symbols,assigns,step.variables);

% solve optimization
[stepsol,subprob] = solve(step,sosc,objective,subprob,options.sosoptions);

% information about subproblem
subprob.LMIsize = stepsol.sizeLMI;

info = setinfo(step,info,subprob);

if ~stepsol.feas
    printf(options,'warning','Step %s infeasible at iteration %d.\n', tostr(step), info.iter);
    % break iteration
    stop = true;
    return
end

% assign outputs
for var=step.varout
    sol.(var{:}) = subs(assigns.(var{:}), stepsol);
end

stop = false;

end