classdef (Abstract) IterativeMethod
% Base class for iterative solvers.
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:tcunis@umich.edu>
% * Created:    2022-03-12
% * Changed:    2022-03-12
%
%%

properties
    prob;
    
    steps;
    options;
end

methods (Access=protected)
    function obj = IterativeMethod(prob, varargin)
        % Create a new iterative methods.
        obj.prob = prob;
        
        obj.options = obj.newoptions(prob.sosf,varargin{:});
        
        obj.steps = {};
    end
end

methods
    [sol,info] = run(obj,varargin);
            
    function obj = addmessage(obj, varargin)
        % Register a message output.
        
        obj = obj.addstep('message',varargin{:});
    end
    
    function obj = addoutputfcn(obj,varargin)
        % Register an output function.
        
        obj = obj.addstep('outputfcn',varargin{:});
    end
end
    
methods (Access=protected) 
    function opt = newoptions(~,varargin)
        % Create new options instance.
        opt = bisos.package.Options(varargin{:});
    end
    
    function step = newstep(~,type,varargin)
        % Create a new step.
        
        step = bisos.iteration.step.(type)(varargin{:});
    end
    
    function obj = addstep(obj,type,varargin)
        % Register a new step.
        
        obj.steps{end+1} = newstep(obj,type,obj.prob,varargin{:});
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
