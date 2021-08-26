classdef (Abstract) AbstractVariable

properties (Abstract,Constant)
    category;
end
    
properties
    id;
    poly;
    
    cidx;
end

properties (Dependent)
    constraints;
end

methods
    function obj = AbstractVariable(sosf,vid,sz)
        % Create new variable.
        if length(sz) == 1
            sz = repmat(sz,1,2);
        end
        
        obj.poly = polyvar(sosf,vid,sz(1),sz(2));
        obj.id = vid;
    end
    
    function varargout = size(obj,varargin)
        % See SIZE.
        varargout = cell(max(1,nargout));
        
        [varargout{:}] = size(obj.poly,varargin{:});
    end
    
    function obj = set.constraints(obj,idx)
        % Append constraint index.
        obj.cidx(end+1) = idx;
    end
end

end
