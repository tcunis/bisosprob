classdef convex < bisos.iteration.OptStep
   
properties
end

methods
    function step = convex(prob,lvar,varargin)
        % New convex optimization step.
        step@bisos.iteration.OptStep(prob,'convex',lvar,varargin{:});
    end
    
    function stepsol = solve(~,sosc,objective,sosoptions)
        % Solve convex optimization step.
        stepsol = optimize(sosc,objective,sosoptions);
    end
    
    function [sosc,assigns] = prepare(~,~,sosc,~,assigns)
        % nothing to do.
    end
end

end