classdef bisect < bisos.iteration.OptStep
    
properties
    bvar;
end

methods
    function step = bisect(prob,lvar,objective,ovar,varargin)
        % New quasi-convex optimization step.
        assert(~isempty(objective), 'Cannot bisect with empty objective.');
        assert(length(ovar) < 2, 'Can only bisect along a single variable.');
        assert(isscalar(prob, ovar{:}), 'Can only bisect along scalar variable.');

        p = getsymbol(prob, ovar);
        assert(isequal(objective,p) || isequal(objective,-p), 'Objective must be ''+%1$s'' or ''-%1$s''.', ovar{:});
        
        step@bisos.iteration.OptStep(prob,'bisect',lvar,ovar,objective,ovar,varargin{:});
        step.bvar = ovar;
    end
    
    function [sosc,assigns] = prepare(step,prob,sosc,symbols,assigns)
        % Prepare bisection.
        [sosc,ovar] = instantiate(prob,sosc,step.ovar);

        assigns.(step.ovar{:}) = ovar;
        assigns.(step.ovar{:}) = bisos.subs(step.objective,symbols,assigns,step.ovar);
    end
    
    function stepsol = solve(~,sosc,objective,sosoptions)
        % Solve quasi-convex optimization step.
        
        
        stepsol = goptimize(sosc,objective,sosoptions);
    end
    
    function [sol,iter,stop] = run(step,prob,iter,sol,symbols,assigns,options)
        % Overwriting OptStep#run
        tlb = options.sosoptions.minobj;
        tub = options.sosoptions.maxobj;
        
        if iter > 1 && max(length(tlb),length(tub)) == 1
            % recover last solution
            obj0 = double(bisos.subs(step.objective,symbols,sol,step.ovar));

            % initial guesses for lower and upper bounds
            tlb = obj0+tlb;
            tub = obj0+tub;
        end
        
        % set lower and upper bounds
        options.sosoptions.minobj = tlb;
        options.sosoptions.maxobj = tub;
        
        % run step as usual
        [sol,iter,stop] = run@bisos.iteration.OptStep(step,prob,iter,sol,symbols,assigns,options);
    end
end

end