classdef objective < bisos.iteration.Step
   
properties
    type = 'obj';
    varout = [];
    varin;
end

methods
    function step = objective(vars)
        % New objective step.
        step.varin = vars;
    end
    
    function [sol,iter,stop] = run(step,prob,iter,sol,symbols,assigns,options)
        % Run objective step.
        for var=step.varin
            assigns.(var{:}) = sol.(var{:});
        end
        
        % set objective
        sol.obj = evalobj(prob,symbols,assigns,step.variables);
        
        printf(options,'step','Objective = %g at iteration %d.\n', sol.obj, iter);
        
        stop = false;
    end
end

end