classdef init < bisos.iteration.Step

properties
    type = 'init';
    varin = [];
    varout;
end

methods
    function step = init(vars)
        % New initialisation step.
        step.varout = vars;
    end
    
    function [sol,info,stop] = run(step,prob,info,sol,varargin)
        % Run initialisation step.
        info.iter = info.iter + 1;
                
        if info.iter == 1
            % initialize solution variables
            for var=step.varout
                [~,sol.(var{:})] = hasinitial(prob,var{:});
            end
        end
        
        stepinfo.sol = sol;
        
        info = setinfo(step,info,stepinfo);
        
        stop = isfield(info,'converged') && info.converged;
    end
    
    function str = name(step)
        % Overriding Step.name
        str = sprintf('%s', step.type);
    end
end

methods (Access=protected)
    function str = varin2str(~)
        % Overriding bisos.iteration.Step#varin2str
        str = 'init';
    end
end

end