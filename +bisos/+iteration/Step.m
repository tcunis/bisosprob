classdef (Abstract) Step
    
properties (Abstract)
    type;
    varin;
    varout;
end

properties (Dependent)
    variables;
end

methods
    function vars = get.variables(obj)
        % Variables involved with step.
        vars = [obj.varin obj.varout];
    end
end

methods (Abstract)
    [sol,iter,stop] = run(obj,prob,iter,sol,symbols,assigns,varargin);
end
    
end
