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
    
    function [sol,assigns,iter,stop] = run(step,prob,iter,sol,~,assigns,varargin)
        % Run initialisation step.
        iter = iter + 1;
        
        stop = false;

        if iter > 1
            return;
        end
        
        % initialize solution variables
        for var=step.varout
            [~,sol.(var{:})] = hasinitial(prob,var{:});
        end
    end
end

end