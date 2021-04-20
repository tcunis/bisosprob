classdef Iteration
% Iteration scheme for bilinear sum-of-square problems.
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:tcunis@umich.edu>
% * Created:    2020-03-28
% * Changed:    2020-03-28
%
%%

properties
    prob;
    
    steps;
    options;
    
    stepgraph;
end

methods
    function obj = Iteration(prob, varargin)
        % Create a new iteration scheme.
        obj.prob = prob;
        
        obj.options = bisos.Options(prob.sosf,varargin{:});
        
        % initial values and objective
        obj.steps = {
            newstep(obj,'init',prob.haveinitials)
            newstep(obj,'objective',prob.objective.lvar)
        };
        
        A = false(2);
        obj.stepgraph = digraph(A);
    end
    
    function obj = addconvex(obj, varargin)
        % Register a convex optimization step.
        
        obj = obj.addstep('convex',varargin{:});
    end
    
    function obj = addbisect(obj, varargin)
        % Register a quasi-convex bisection step.
        
        obj = obj.addstep('bisect',varargin{:});
    end
end

methods
    G = graph(obj,G);
    G = route(obj);
end

methods (Access=private)
    obj = addstep(obj,type,lvar,objective,ovar,varargin);

    function step = newstep(~,type,varargin)
        % Create a new step.
        
        step = bisos.iteration.step.(type)(varargin{:});
    end
    
    function step = getstep(obj,i)
        % Return i-th step.
        step = obj.steps{i};
    end
end

end
