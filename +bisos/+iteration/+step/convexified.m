classdef convexified < bisos.iteration.Step
    
properties
    type = 'convexified';
end
    
properties (Dependent)
    varin;
    varout;
end

properties
    decnames;
    subnames;
end 

methods
    function step = convexified(prob)
        % New convexified optimization step.
        step.decnames = prob.getvariables('decvars');
        step.subnames = prob.getvariables('subvars');
    end
    
    function vars = get.varin(step)
        % Input variables.
        vars = step.decnames;
    end
    
    function vars = get.varout(step)
        % Output variables.
        vars = [step.decnames step.subnames];
    end
    
    function [sol,info,stop] = run(step,prob,info,sol,symbols,assigns,options)
        % Run convexified optimization step.
        
        sosc = newconstraints(prob.sosf,prob.x);
        
        for var=step.decnames
            [sosc,assigns.(var{:})] = instantiate(prob,sosc,var);
            prevsol.(var{:}) = sol.(var{:});
        end
        for var=step.subnames
            [sosc,assigns.(var{:})] = evaluate(prob,sosc,var,symbols,assigns);
            [sosc,prevsol.(var{:})] = evaluate(prob,sosc,var,symbols,prevsol);
        end
        
        % previous constraint
        [g0,X,X0] = bisos.subs(prob.soscons,symbols,prevsol);
        
        % local derivative
        J0 = bisos.subs(jacobian(prob.soscons,prob.sosf,X),symbols,prevsol);
        
        % local constraint
        lsoscon = g0 + dot(J0, X - X0);
        
        % prepare linear objective
        objective = bisos.subs(prob.objective.obj,symbols,assigns);
        
        sosc = realize(lsoscon,sosc,symbols,assigns);
        
        % solve optimization
        stepsol = optimize(sosc,objective,options.sosoptions);
        
        if ~stepsol.feas
            printf(options,'warning','Step %s infeasible at iteration %d.\n', tostr(step), info.iter);
            % break iteration
            stop = true;
            return
        end
        
        % line search (experimental)
        X1 = subs(bisos.subs(X,symbols,assigns), stepsol);
        
        pvar d
        % objective & nonlinear constraints along d
        objd = subs(prob.objective.obj,X,(1-d)*X0 + d*X1);
        gd = subs(prob.soscons.oneside,X,(1-d)*X0 + d*X1);
        
        % merit function
        merit = objd - feval(stepsol.dual,gd);
        
        bnds = options.stepbnds;
        dopt = fminbnd(@(y) double(subs(merit,d,y)), bnds(1), bnds(2));
        
        % assign outputs
        for var=step.varout
            sol.(var{:}) = subs(symbols.(var{:}),X,(1-dopt)*X0 + dopt*X1);
        end
        
        p = stepsol.primal;
        d = stepsol.dual;
        if info.iter > 1
            % not first iteration
            stepinfo = getinfo(step,info);
            
            info.converged = ( double(pnorm2(p - stepinfo.primal)) < options.abstol ... *double(pnorm2(p)) ...
                && double(dnorm2(d - stepinfo.dual)) < options.reltol*double(dnorm2(d)) );
        end
        
        stepinfo.primal = p; stepinfo.dual = d;
        stepinfo.stepsize = dopt;
        % information about subproblem
        stepinfo.subprob.size = stepsol.sizeLMI;
        stepinfo.subprob.info = stepsol.solverinfo;
        
        stepinfo = checkfeasibility(step,'step',prob,stepinfo,sol,options);
        
        assertfeas(options,stepinfo.feastol,'warning','Infeasible nonlinear solution at iteration %d.\n', info.iter);

        info = setinfo(step,info,stepinfo);
        
        stop = false;
    end
    
    function stop = run_final(step,prob,info,sol,options)
        % Overwriting Step#run_final
        info = checkfeasibility(step,'result',prob,info,sol,options);
        
        assertfeas(options,info.feastol,'result','Infeasible nonlinear solution at last iteration.\n');
        
        stop = false;
    end
end

methods (Access=private)
    function info = checkfeasibility(step,lvl,prob,info,sol,options)
    % Check feasibility of solution.
        if ~checkfeasibility(options,lvl)
            % nothing to do
            info.feastol = [];
            return
        end

        % else:
        sosc = newconstraints(prob.sosf,prob.x);

        for var=step.variables
            symbols.(var{:}) = getsymbol(prob,var);
            assigns.(var{:}) = sol.(var{:});
        end

        % tolerance
        [sosc,eps] = decvar(sosc,1);

        % nonlinear constraint at current solution
        sosc = realize(prob.soscons,sosc,symbols,assigns,step.variables,eps);

        feassol = optimize(sosc,eps,options.sosoptions);

        % store feasibility tolerance
        info.feastol = feassol.obj;
    end
end

end