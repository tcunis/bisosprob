classdef Sequential < bisos.package.IterativeMethod
% Sequential solver algorithm for nonlinear sum-of-squares problems.

properties
    %prob;
    
    %steps;
end

methods
    function obj = Sequential(prob, varargin)
        % Create a new sequential scheme.
        obj@bisos.package.IterativeMethod(prob, varargin{:});
        
        % base steps
        obj.steps = {
            newstep(obj,'init',getvariables(prob,'decvars'))
            newstep(obj,'convexified',prob)
            newstep(obj,'objective',prob.objective.lvar)
        }';
    end
end

methods (Access=protected)
    function opt = newoptions(~,varargin)
        % Create new options instance.
        opt = bisos.sequential.Options(varargin{:});
    end
end

end