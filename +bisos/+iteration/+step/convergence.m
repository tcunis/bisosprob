classdef convergence < bisos.iteration.Step
   
properties
    type = 'convergence';
    varout = [];
    varin;
    
    levels;
    
    % default properties for convergence verification
    options = struct('ctol', 10^-9, 'domain', [-1 1]);
    
end

methods
    function step = convergence(prob, vars, varargin)
        % new level set convergence setup
        
        step.varin = {};
        
        % get name of variables that the step needs to start
        for v = vars(:)'
            if isa(v{:}, 'char')
                assert(hasvariable(prob,v), 'Unknown variable ''%s''.', v{:});
                step.varin(end+1) = v;
            end
        end
        
        % reshape level sets into cell matrix L
        % where L{i,1} is the i-th polynomial and L{i,2} is the i-th level
        step.levels = reshape(vars,[],2)';
        
        % assign options
        varargin = [varargin{:}];
        for i=1:2:length(varargin)
            name = varargin{i}; value = varargin{i+1};
            assert(isfield(step.options, name), 'Unknown option ''%s''.', name);

            step.options.(name) = value;
        end
    end
    
    function [sol,info,stop] = run(step,prob,info,sol,varargin)
        % Run objective step.
        
        stop = false;

        curr_levels = cell(size(step.levels));
        
        % loop to get variables value in sol
        for i = 1:length(step.levels(:))
            var = step.levels{i};
            if isa(var,'char')
                curr_levels{i} = sol.(var);
            else
                curr_levels{i} = var;
            end
        end
            
        if info.iter > 1
            stepinfo = getinfo(step,info);
            
            prev_levels = stepinfo.levels;
            
            currL = [curr_levels{:,1}];
            currR = [curr_levels{:,2}];
            
            prevL = [prev_levels{:,1}];
            prevR = [prev_levels{:,2}];
            
            pol = (currL./currR - prevL./prevR).^2;

            volume = step.poly_diff(prob.x, pol, step.options.domain);

            if all(volume < step.options.ctol)
                info.converged = true;
            end
        end
            
        % store 'previous' levels for next iteration
        stepinfo.levels = curr_levels;
        
        info = setinfo(step,info,stepinfo);
    end
end

methods (Static, Access=private)
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