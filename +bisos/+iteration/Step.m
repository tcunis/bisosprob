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
    [sol,info,stop] = run(obj,prob,info,sol,symbols,assigns,varargin);
end

methods
    function vars = get.variables(obj)
        % Variables involved with step.
        vars = union(obj.varin, obj.varout);
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
    function sub = getinfo(obj,info)
        % Get step-specific information from info struct.
        str = tostr(obj);
        sub = info.steps.(str);
    end
    
    function info = setinfo(obj,info,sub)
        % Set step-specific information in info struct.
        str = tostr(obj);
        sub.stepname = str;
        info.steps.(str) = sub;
    end
    
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

methods
    function stop = run_final(~,varargin)
        % Run step for the final time.
        stop = false;
    end
end

end
