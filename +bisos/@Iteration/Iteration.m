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
        }';
        
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
    
    function obj = addbiconv(obj, varargin)
        % Register a biconvex bisection step.
        
        obj = obj.addstep('biconv',varargin{:});
    end
    
    function obj = addmessage(obj, varargin)
        % Register a message output.
        
        obj = obj.addstep('message',varargin{:});
    end
    
    function obj = addoutputfcn(obj,varargin)
        % Register an output function.
        
        obj = obj.addstep('outputfcn',varargin{:});
    end
    
    function obj = addconvergence(obj,varargin)
        % Check for convergence of level sets.
        
        obj = obj.addstep('convergence',varargin{:});
    end
    
    function obj = addtermination(obj, varargin)
        % Register a termination rule.
        
        obj = obj.addstep('termination',varargin{:});
    end
    
    function obj = addtransfer(obj, varargin)
        % Register transfer operation.
        
        obj = obj.addstep('transfer',varargin{:});
    end
end

methods
    G = graph(obj,G);
    G = route(obj);
end

methods (Access=private)
    obj = addstep(obj,type,varargin);

    function step = newstep(~,type,varargin)
        % Create a new step.
        
        step = bisos.iteration.step.(type)(varargin{:});
    end
    
    function step = getstep(obj,i)
        % Return i-th step.
        step = obj.steps{i};
    end
    
    function obj = complete(obj,G)
        % Add dummy steps to match graph representation.
        obj.steps(end+1:numnodes(G)) = {newstep(obj,'dummy')};
    end
end

end
