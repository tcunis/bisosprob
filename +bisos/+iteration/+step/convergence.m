classdef convergence < bisos.iteration.Step
   
properties
    type = 'convergence';
    varout = [];
    varin;
end

methods
    function step = convergence(prob, vars)
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
        
        if(step.poly_diff(prob, aux)<10^-9)
            stop = true;
            return 
        end
        
        stop = false;
    end
    
    function Volume = poly_diff(step, prob, diff)
        x = -1:0.01:1;
        [xx,yy] = ndgrid(x,x);
        for i= length(x)
            for j=1:length(x)
                mat(i,j) = double(subs(diff,prob.x,[xx(i,j);yy(i,j)]));
            end
        end
         
        b{1} = x;
        b{2} = x;
        
        Volume = step.trapezoidal_rule_nd_integral(b, mat, 2);
        
    end
    
    function out = trapezoidal_rule_nd_integral(step,x, mat, N)
        mat = trapz(x{N},mat, N);
        if N==1
            out=mat;
            return;
        end
        out = step.trapezoidal_rule_nd_integral(x, mat, N-1);
    end
end

methods (Access=protected)
    function str = varout2str(~)
        % Overriding bisos.iteration.Step#varout2str
        str = 'converg';
    end
end

end