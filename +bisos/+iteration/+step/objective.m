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
    
    function [sol,info,stop] = run(step,prob,info,sol,symbols,assigns,options)
        % Run objective step.
        for var=step.varin
            assigns.(var{:}) = sol.(var{:});
        end
        
        % set objective
        sol.obj = evalobj(prob,symbols,assigns,step.variables);
        
        printf(options,'step','Objective = %g at iteration %d.\n', sol.obj, info.iter);
        
        writetofile(options,'step',sol,'iter%d',info.iter);
        
        stop = false;
    end
    
    function stop = run_final(~,~,info,sol,options)
        % Run final objective step.
        
        printf(options,'result','Stopped after %d iterations with objective = %g.\n', info.iter, sol.obj);
        
        writetofile(options,'result',sol,'result');
        
        stop = false;
    end
end

methods (Access=protected)
    function str = varout2str(~)
        % Overriding bisos.iteration.Step#varout2str
        str = 'obj';
    end
end

end