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
        
        % assign outputs
        for var=step.varout
            sol.(var{:}) = subs(assigns.(var{:}), stepsol);
        end
        
        if options.checkfeas
            sosc1 = newconstraints(prob.sosf,prob.x);
            
            % nonlinear constraint at current solution
            sosc1 = realize(prob.soscons,sosc1,symbols,sol,step.variables,options.feastol);
            
            feassol = optimize(sosc1); %,[],options.sosoptions);
            
            if ~feassol.feas
                printf(options,'warning','Infeasible nonlinear solution at iteration %d.\n', info.iter);
            end
        end

        p = stepsol.primal;
        d = stepsol.dual;
        if info.iter > 1
            % not first iteration
            stepinfo = getinfo(step,info);
            
            info.converged = ( double(pnorm2(p - stepinfo.primal)) < 1e-5 ...
                && double(dnorm2(d - stepinfo.dual)) < 1e-5 );
        end
        
        stepinfo.primal = p; stepinfo.dual = d;
        % information about subproblem
        stepinfo.subprob.size = stepsol.sizeLMI;
        stepinfo.subprob.info = stepsol.solverinfo;
        
        info = setinfo(step,info,stepinfo);
        
        stop = false;
    end
end

end

        