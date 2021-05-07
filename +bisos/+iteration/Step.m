classdef (Abstract) Step
    
properties (Abstract)
    type;
    varin;
    varout;
end

properties (Dependent)
    variables;
end

methods (Abstract)
    [sol,iter,stop] = run(obj,prob,iter,sol,symbols,assigns,varargin);
end

methods
    function vars = get.variables(obj)
        % Variables involved with step.
        vars = [obj.varin obj.varout];
    end
    
    function str = tostr(obj)
        % Return string representation for step.
        
        str = sprintf('%s -> %s', obj.varin2str, obj.varout2str);
    end
    
    function disp(obj)
        % Display step.
        
        fprintf('  Step %s\n\n', obj.tostr);
    end
end

methods (Access=protected)
    function str = varin2str(obj)
        % String representation input variables.
        c = @(s) s(1:end-1);
        str = c(sprintf('%s,',obj.varin{:}));
    end
    
    function str = varout2str(obj)
        % String representation output variables.
        c = @(s) s(1:end-1);
        str = c(sprintf('%s,',obj.varout{:}));
    end
end

end
