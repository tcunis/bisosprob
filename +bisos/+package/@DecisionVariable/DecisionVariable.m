classdef DecisionVariable < bisos.package.AbstractVariable
    
properties (Constant)
    category = 'decvars';
end
    
properties
    type;
    
    z;
    pol0;
    
    subs;
end

properties (Dependent)
    subsidiaries;
    initial;
end

methods
    function [obj,p] = DecisionVariable(sosf,vid,type,sz,z,p0)
        % Create new decision variable.
        if nargin < 6
            p0 = [];
        end
        
        obj@bisos.package.AbstractVariable(sosf,vid,sz);
        
        obj.type = type;
        obj.pol0 = p0;
        obj.z = z;
        
        p = obj.poly;
    end
end

methods
    %% Package interface
    [sosc,p] = instantiate(obj,sosc);
    
    function obj = set.subsidiaries(obj,var)
        % Append subsidiary variable.
        obj.subs{end+1} = var;
    end
    
    function obj = set.initial(obj,p0)
        % Set initial guess.
        obj.pol0 = p0;
    end
    
    function [tf,p0] = hasinitial(obj)
        % Check if variable has initial value set.
        p0 = obj.pol0;
        tf = ~isempty(p0);
    end
    
    function tf = isscalar(obj)
        % Check if variable is scalar.
        tf = all(size(obj) == 1) && isempty(obj.z);
    end
end

end
