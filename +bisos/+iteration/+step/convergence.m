classdef convergence < bisos.iteration.Step
   
properties
    type = 'convergence';
    varout = [];
    varin;
end

methods
    function step = convergence(~, vars)
        % New check convergence step.
        step.varin = vars;
    end
    
    function [sol,info,stop] = run(step,prob,info,sol,symbols,assigns,options, varargin)
        % Run objective step.
        
        if info.iter==1
           stop = false;
           return 
        end
        
        for var=step.varin
            assigns.(var{:}) = sol.(var{:});
        end
        
        for var=step.varin
           prev.(var{:}) = varargin{:}(info.iter - 1).(var{:}); 
        end
        
        aux = (assigns.(step.varin{1})/assigns.(step.varin{2})...
            -prev.(step.varin{1})/prev.(step.varin{2}))^2;
        
        if(step.poly_diff(prob, aux)<10^-11)
            info.converged = true;
            stop=false;
            return 
        end
        
        stop = false;
    end
    
    function Volume = poly_diff(~, prob, diff)
        
        for i = 1:length(prob.x)
           diff = int(diff, prob.x(i), [-1 1]);  
        end
        
        Volume = double(diff)/2^length(prob.x);
        
    end
    
end

methods (Access=protected)
    function str = varout2str(~)
        % Overriding bisos.iteration.Step#varout2str
        str = 'converg';
    end
end

end