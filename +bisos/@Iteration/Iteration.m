classdef Iteration < bisos.package.IterativeMethod
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
    %prob;
    
    %steps;
    %options;
    
    stepgraph;
end

methods
    function obj = Iteration(prob, varargin)
        % Create a new iteration scheme.
        obj@bisos.package.IterativeMethod(prob, varargin{:});
        
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
    
    function obj = addconvergence(obj,varargin)
        % Check for convergence of level sets
        
        obj = obj.addstep('convergence',varargin{:});
    end
    
    function obj = addtermination(obj, varargin)
        % Register a termination rule
        
        obj = obj.addstep('termination',varargin{:});
    end
end

methods
    G = graph(obj,G);
    G = route(obj);
    
    function [sol,info] = run(obj,varargin)
        % Overwriting IterativeMethod#run
        if nargin > 1 
            % nothing to do
        elseif isrouting(obj.options, 'auto')
            % automatic routing
            varargin = {route(obj)};
        end

        [sol,info] = run@bisos.package.IterativeMethod(obj,varargin{:});
    end
end

methods (Access=protected)
    obj = addstep(obj,type,varargin);
    
    function opt = newoptions(~,varargin)
        % Create new options instance.
        opt = bisos.iteration.Options(varargin{:});
    end
end

end
