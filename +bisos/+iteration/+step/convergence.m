classdef convergence < bisos.iteration.Step
   
properties
    type = 'convergence';
    varout = [];
    varin;
    data_prev = true;
    
    levels;
    
    % default properties for convergence verification
    options = struct('ctol', 10^-9, 'domain', [-1 1]);
    
end

methods
    function step = convergence(~, vars, varargin)
        % new level set convergence setup
        
        % get name of variables that the step needs to start
        for i = 1:length(vars)
            if isa(vars{i}, 'char')
                step.varin{length(step.varin)+1} = vars{i};
            end
        end
         
        for i = 1:2:length(vars)
           step.levels{length(step.levels)+1} = {vars{i} vars{i+1}};   
        end
        
        for i=1:2:length(varargin{:})
            if isfield(step.options, varargin{:}{i})
                step.options.(varargin{:}{i}) = varargin{:}{i+1};
            end
        end
    end
    
    function [sol,info,stop] = run(step,prob,info,sol,symbols,assigns,options)
        % Run objective step.
        
        stop = false;

        if info.iter==1
           return 
        else
            info.converged = true;
        end

        % loop to get variables value in sol from current and last cycle
        for i = 1:length(step.levels)
            
            level = step.levels{i};
            
            if isa(level{1}, 'char')
               pres{1} = sol.(level{1});
               prev{1} = info.solutions(info.iter - 1).(level{1}); 
            else
               pres{1} = level{1};
               prev{1} = level{1}; 
            end
            
            if isa(level{2}, 'char')
               pres{2} = sol.(level{2});
               prev{2} = info.solutions(info.iter - 1).(level{2});
            else
               pres{2} = level{2};
               prev{2} = level{2};
            end
            
            pol = (pres{1}/pres{2} - prev{1}/prev{2})^2;
            
            volume = step.poly_diff(prob.x, pol, step.options.domain);

            info.converged = info.converged && (volume < step.options.ctol);
        end
    end
end

methods(Static)
    function volume = poly_diff(x, pol, domain)
        % perform integral over a hypercube 
        % the integral is exact with no approximations envolved
        % ONLY WORKS FOR POLYNOMIALS OF Sosoptfatory
        for i = 1:length(x)
           pol = int(pol, x(i), domain);  
        end
        
        volume = double(pol)/(domain(2)-domain(1))^length(x);
    end  
end

methods (Access=protected)
    function str = varout2str(~)
        % Overriding bisos.iteration.Step#varout2str
        str = 'converg';
    end
end

end