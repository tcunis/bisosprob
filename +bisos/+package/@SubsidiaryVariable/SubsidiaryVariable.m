classdef SubsidiaryVariable < bisos.package.AbstractVariable
    
properties (Constant)
    category = 'subvars';
end
    
properties
    fhan;
    
    lvar;
    args;
end

properties (Dependent)
    varin;
end

methods
    function [obj,q] = SubsidiaryVariable(sosf,id,sz,f,lvar,args)
        % Create new subsidiary variable.
        if nargin < 6
            args = [];
        elseif ~isempty(args)
            warning('Arguments for subsidary variables are not supported yet.');
        end
        
        obj@bisos.package.AbstractVariable(sosf,id,sz);
        
        obj.fhan = f;
        obj.lvar = lvar;
        obj.args = args;
        
        q = obj.poly;
    end
end

methods
    %% Package interface
    [sosc,p] = evaluate(obj,sosc,symbols,assigns);
    
    function vars = get.varin(obj)
        % Input variables.
        vars = [obj.lvar obj.args];
    end
end

end