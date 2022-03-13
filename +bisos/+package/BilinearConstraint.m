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
    
    function C = subs(obj,varargin)
        % Substitute variables in constraints.
        if ~islist(obj)
            Clhs = subs(obj.lhs,varargin{:});
            Crhs = subs(obj.rhs,varargin{:});
            cons = {Clhs,obj.cmp,Crhs,obj.lvar,obj.bvar};
        else
            cons = {arrayfun(@(c) subs(c,varargin{:}),obj,'UniformOutput',false)};
        end
        
        C = bisos.package.BilinearConstraint(cons{:});
    end
    
    function J = jacobian(obj,sosf,x)
        % Compute Jacobian of constraints.
        if ~islist(obj)
            Jlhs = sosf.jacob(obj.lhs,x);
            Jrhs = sosf.jacob(obj.rhs,x);
            cons = {Jlhs,obj.cmp,Jrhs,obj.lvar,obj.bvar};
        else
            cons = {arrayfun(@(c) jacobian(c,sosf,x),obj,'UniformOutput',false)};
        end
        
        J = bisos.package.BilinearConstraint(cons{:});
    end
    
    function C = plus(obj,B)
        % Add to constraints.
        if ~isa(B,'bisos.package.BilinearConstraint')
            % TODO
            error('Operation not supported for %s.',class(B));
        end
        
        % else:
        assert(isequal(obj.cmp,B.cmp), 'Dimensions and comparators must agree.')
        
        if ~islist(obj)
            Clhs = plus(obj.lhs,B.lhs);
            Crhs = plus(obj.rhs,B.rhs);
            Clvar = unique([obj.lvar B.lvar]);
            Cbvar = unique([obj.lvar B.lvar]);
            cons = {Clhs,obj.cmp,Crhs,Clvar,Cbvar};
        else
            cons = {cellfun(@(a,b) plus(a,b),cell(obj),cell(B),'UniformOutput',false)};
        end
        
        C = bisos.package.BilinearConstraint(cons{:});
    end
    
    function C = dot(obj,b)
        % Scalar dot product with polynomial.
        if ~islist(obj)
            Clhs = mtimes(obj.lhs,b);
            Crhs = mtimes(obj.rhs,b);
            cons = {Clhs,obj.cmp,Crhs,obj.lvar,obj.bvar};
        else
            cons = {arrayfun(@(c) dot(c,b),obj,'UniformOutput',false)};
        end
        
        C = bisos.package.BilinearConstraint(cons{:});
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
        elseif length(ops) > 1
            cmp = ops;
        else
            cmp = ops{:};
        end
    end
end

end
