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
        obj.steps = newstep(obj,{'init' 'obj'},[],[],[],[],{[] prob.objective.lvar},{prob.haveinitials []},[]);
        
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

    function step = newstep(~,type,objective,varargin)
        % Create a new step struct.
        if length(varargin) < 6
            varargin{6} = [];
        end
        
        step = struct('type',type,'lvar',varargin{1},'obj',objective,'ovar',varargin{2},'cidx',varargin{3},'varin',varargin{4},'varout',varargin{5},'subnames',varargin{6});
    end
    
    function sol = runstep(~,step,sosc,sosoptions)
        switch step.type
            case 'convex'
                % solve convex optimization
                sol = optimize(sosc,step.obj,sosoptions);

            case 'bisect'
                % solve bisection
                sol = goptimize(sosc,step.obj,sosoptions);
                
            otherwise
                error('Cannot solve %s-step.', step.type);
        end
    end
    
end

end
