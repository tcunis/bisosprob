classdef (InferiorClasses={?function_handle}) BilinearConstraint
    
properties (Dependent)
    lhs;
    rhs;
    cmp;
    
    lvar;
    bvar;
end

properties
    data;
    list;
end

properties (Dependent)
    variables;
    append;
end

methods (Access=protected)
    function obj = BilinearConstraint(lhs,cmp,rhs,lvar,bvar)
        % New bilinear SOS constraint.
        if nargin == 1
            obj.list = lhs;
            return
        end
        
        % else:
        if nargin < 5
            bvar = [];
        end
        
        data.lhs = lhs;
        data.rhs = rhs;
        data.cmp = cmp;
        
        data.lvar = lvar;
        data.bvar = bvar;
        
        obj.data = data;
    end
    
    function tf = islist(obj)
        % Check if list of constraints.
        tf = isempty(obj.data);
    end
    
    function c = getdata(obj,name)
        % Query constraint data.
        if islist(obj)
            c = arrayfun(@(c) c.(name), obj, 'UniformOutput', false);
        else
            c = {obj.data.(name)};
        end
    end
end

methods
    function vars = get.variables(obj)
        % All variables involved in constraint.
        vars = unique([obj.lvar obj.bvar]);
    end
    
    function sosc = realize(obj,sosc,varargin)
        % Add to SOS constraints.
        if ~islist(obj)
            LHS = bisos.subs(obj.lhs,varargin{:});
            RHS = bisos.subs(obj.rhs,varargin{:});

            sosc = obj.cmp(sosc,LHS,RHS);
            return
        end
        
        % else:
        for c = obj.list
            sosc = realize(c{:},sosc,varargin{:});
        end
    end
    
    function tf = islinear(obj)
        % Check if constraint(s) are linear in all variables.
        tf = isempty(obj.bvar);
    end
end

methods (Static)
    function cons = eq(lhs,rhs,varargin)
        % New equality constraint.
        cons = bisos.package.BilinearConstraint(lhs,@eq,rhs,varargin{:});
    end
    
    function cons = le(lhs,rhs,varargin)
        % New lower-than-or-equal constraint.
        cons = bisos.package.BilinearConstraint(lhs,@le,rhs,varargin{:});
    end
    
    function cons = ge(lhs,rhs,varargin)
        % New greater-than-or-equal constraint.
        cons = bisos.package.BilinearConstraint(lhs,@ge,rhs,varargin{:});
    end
    
    function C = empty
        % Empty list of constraints.
        C = bisos.package.BilinearConstraint({});
    end
end

methods
    function obj = set.append(obj,cons)
        % Append constraint.
        obj = [obj cons];
    end
    
    function tf = isempty(obj)
        % Check if constraint array is empty.
        tf = isempty(cell(obj));
    end
    
    function varargout = size(obj,varargin)
        % Return size of constraint array.
        [varargout{1:nargout}] = size(cell(obj),varargin{:});
    end
    
    function N = length(obj)
        % Return length of constraint array.
        N = length(cell(obj));
    end
    
    function c = cell(obj)
        % Convert constraint array into cell array of constraints.
        if islist(obj)
            c = obj.list;
        else
            c = {obj};
        end
    end
    
    function C = cat(~,varargin)
        % Concatenation.
        cons = cellfun(@(c) cell(c), varargin, 'UniformOutput', false);
        C = bisos.package.BilinearConstraint(horzcat(cons{:}));
    end
    
    function C = vertcat(varargin)
        % Vertical concatenation.
        C = cat(1,varargin{:});
    end
    
    function C = horzcat(varargin)
        % Horizontal concatenation.
        C = cat(2,varargin{:});
    end
    
    function varargout = arrayfun(func,obj,varargin)
        % Apply function to each constraint.
        f = @(c,varargin) func(c{:},varargin{:});
        [varargout{1:nargout}] = arrayfun(f, cell(obj), varargin{:});
    end
    
    function varargout = subsref(obj,S)
        % Subscripted reference.
        if isempty(S)
            varargout = {obj};
        elseif strcmp(S(1).type, '()')
            C = bisos.package.BilinearConstraint(subsref(cell(obj),S(1)));
            [varargout{1:nargout}] = subsref(C, S(2:end));
        else
            [varargout{1:nargout}] = builtin('subsref',obj,S);
        end
    end     
    
    function lhs = get.lhs(obj)
        % Left-hand side of constraint.
        terms = getdata(obj,'lhs');
        lhs = vertcat(terms{:});
    end
    
    function rhs = get.rhs(obj)
        % Right-hand side of constraint.
        terms = getdata(obj,'rhs');
        rhs = vertcat(terms{:});
    end
    
    function lvar = get.lvar(obj)
        % Linear variables.
        vars = getdata(obj,'lvar');
        lvar = unique([{} vars{:}]);
    end
    
    function bvar = get.bvar(obj)
        % Bilinear variables.
        vars = getdata(obj,'bvar');
        bvar = unique([{} vars{:}]);
    end
    
    function cmp = get.cmp(obj)
        % Comparison operator.
        ops = getdata(obj,'cmp');
        if isempty(ops)
            cmp = [];
        else
            cmp = ops{1};
        end
    end
end

end
