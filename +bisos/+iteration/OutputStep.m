classdef (Abstract) OutputStep < bisos.iteration.Step
    
properties
    type;
    varin;
    varout = [];
end

methods
    function obj = OutputStep(type,vars)
        % New output step.
        obj.type = type;
        obj.varin = vars;
    end
    
    function [sol,iter,stop] = run(obj,~,iter,sol,~,~,options)
        % Run output step.
        args = cellfun(@(var) sol.(var), obj.varin, 'UniformOutput', false);
        
        stop = run_output(obj,iter,options,args{:});
    end
end

methods (Abstract, Access=protected)
    stop = run_output(obj,iter,options,varargin);
end

methods (Access=protected)
    function str = varout2str(obj)
        % Overriding bisos.iteration.Step#varout2str
        str = obj.type;
    end
end

end