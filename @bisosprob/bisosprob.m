classdef bisosprob
% Bilinear sum-of-squares problem definition.
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:tcunis@umich.edu>
% * Created:    2020-03-26
% * Changed:    2020-03-31
%
%%
    
properties
    sosf;
    x;
    
    decvars = [];
    subvars = [];
    soscons = struct('lhs',{}, 'rhs',{}, 'cmp',{}, 'lvar',{}, 'bvar',{});
    
    objective;
end

methods
    %% Public interface
    G = graph(obj);
    disp(obj);
    
    function obj = bisosprob(factory,x)
        % Create a new, empty bilinear SOS problem.
        obj.sosf = factory;
        obj.x = x;
    end

    function [obj,a] = decvar(obj,var,varargin)
        % Register a new scalar decision variable |var|.
        
        [obj,a] = obj.addmdecvar(var,1,'',[],varargin{:});
        
        %TODO: set min/max 
    end
    
    function [obj,p] = polydecvar(obj,var,z,varargin)
        % Register a new polynomial decision variable |var| with vector of
        % monomials z and optional initial assignment p0.
        
        [obj,p] = obj.addmdecvar(var,1,'poly',z,varargin{:});
    end
    
    function [obj,s] = sosdecvar(obj,var,z,varargin)
        % Register a new sum-of-squares decision variable |var| with vector
        % of monomials z and optional initial assignment p0.
        
        [obj,s] = obj.addmdecvar(var,1,'sos',z,varargin{:});
    end
    
    function [obj,q] = substitute(obj,var,f,varargin)
        % Register a new subsituting variable |var| with function handle
        % and (linear) arguments.
        
        args = cellfun(@(var) getvariable(obj,var), varargin, 'UniformOutput', false);
        sz = size(f(args{:}));
        
        [obj,q] = obj.addsubsvar(var,sz,f,varargin{:});
    end
    
    function obj = eq(obj,a,b,varargin)
        % Register a new equality constraint 
        % with linear and bilinear decision variables.
        
        obj = obj.addconstraint(a,@eq,b,varargin{:});
    end
    
    function obj = le(obj,a,b,varargin)
        % Register a new lower-than-or-equal constraint (SOS sense)
        % with linear and bilinear decision variables.
        
        obj = obj.addconstraint(a,@le,b,varargin{:});
    end
    
    function obj = ge(obj,a,b,varargin)
        % Register a new greater-than-or-equal constraint (SOS sense)
        % with linear and bilinear decision variables.
        
        obj = obj.addconstraint(a,@ge,b,varargin{:});
    end
    
    function obj = setinitial(obj,var,p0)
        % Set an initial guess for a registered decision variable.
        
        obj.decvars.(var).p0 = p0;
    end
    
    function obj = setobjective(obj,objective,lvar)
        % Set the objective function.
        
        obj.objective = struct('obj', objective, 'lvar', []);
        obj.objective.lvar = lvar;
    end
end

methods (Access=private)
    %% Private methods
    function [obj,p] = addmdecvar(obj,var,sz,type,z,p0)
        % Register a new decision variable.
        if nargin < 6
            p0 = [];
        end
        if length(sz) == 1
            sz = repmat(sz,1,2);
        end
        
        p = polyvar(obj.sosf, var, sz(1), sz(2));
        obj.decvars.(var) = struct('id', var, 'var', p, 'type', type, 'sz', sz, 'z', z, 'p0', p0, 'subs', [], 'cidx', []);
    end
    
    function [obj,q] = addsubsvar(obj,var,sz,f,lvar,args)
        % Register a new subsidary variable.
        if nargin < 6
            args = [];
        elseif ~isempty(args)
            warning('Arguments for subsidary variables are not supported yet.');
        end
        if length(sz) == 1
            sz = repmat(sz,1,2);
        end
        
        q = polyvar(obj.sosf, var, sz(1), sz(2));
        obj.subvars.(var) = struct('id', var, 'var', q, 'sz', sz, 'fhan', f, 'lvar', [], 'args', [], 'cidx', []);
        obj.subvars.(var).lvar = lvar;
        obj.subvars.(var).args = args;
        
        for p=[lvar args]
            assert(obj.hasvariable(p, 'decvars'), 'Unknown decision variable ''%s''.', p{:});
            
            obj.decvars.(p{:}).subs{end+1} = var;
        end
    end
    
    function obj = addconstraint(obj,a,cmp,b,lvar,bvar)
        % Register a new constraint.
        if nargin < 6
            bvar = [];
        end
        
        cons.lhs = a;
        cons.rhs = b;
        cons.cmp = cmp;
        cons.lvar = lvar;
        cons.bvar = bvar;
        
        N = length(obj.soscons);
        obj.soscons(N+1,:) = cons;
        
        for p=[lvar bvar]
            [tf,type] = obj.hasvariable(p);
            
            assert(tf, 'Unknown variable ''%s''.', p{:});
            
            obj.(type).(p{:}).cidx(end+1) = N+1;
        end
    end
end

methods
    %% Package interface
    [sosc,p] = instantiate(obj,sosc,decvar);
    sosc = constraint(obj,sosc,cidx,fvar,avar);
    [sosc,p] = evaluate(obj,sosc,subvar,fvar,avar);
    d = evalobj(obj,var,sol);
    
    function vars = getvariables(obj,type)
        % Return list of variables of |type|.
        if nargin < 2
            vars = [getvariables(obj,'decvars'), getvariables(obj,'subvars')];
        else
            vars = fieldnames(obj.(type))';
        end
    end
    
    function p = getvariable(obj,var)
        % Return polynomial variable object.
        [tf,type] = hasvariable(obj,var);
        if iscell(var), var = var{:}; end
        
        assert(tf, 'Unknown variable ''%s''.', var);
        p = obj.(type).(var).var;
    end
    
    function c = getconstraints(obj,var,caller)
        % Return indizes of constraints involving a variable.
        [tf,type] = hasvariable(obj,var);
        if iscell(var), var = var{:}; end
        
        assert(tf, 'Unknown variable ''%s''.', var);
                    
        var = obj.(type).(var);
    
        % also get constraints of parental / derived variables
        if nargin > 2 && isequal(var.id,caller.id)
            % avoid infinite loop
            c = [];
            return
        elseif nargin < 3
            caller = var;
        end
           
        % else:
        if strcmp(type,'decvars')
            cs = cellfun(@(sub) getconstraints(obj,sub,caller), [var.subs {}], 'UniformOutput', false);
        
        elseif strcmp(type,'subvars')
            cs = cellfun(@(arg) getconstraints(obj,arg,caller), [var.lvar var.args], 'UniformOutput', false);
        end
        
        c = unique([var.cidx cs{:}]);
    end
    
    function tf = hasobjective(obj)
        % Check if objective has been set.
        tf = ~isempty(obj.objective);
    end
    
    function [tf,p0] = hasinitial(obj,var)
        % Check if variable has initial value set.
        
        if ischar(var) 
            var = obj.decvars.(var);
        end
        
        p0 = var.p0;
        tf = ~isempty(p0);
    end
    
    function vars = haveinitials(obj)
        % Return list of variables with initial values.
        ldecvars = getvariables(obj,'decvars');
        initials = cellfun(@(var) hasinitial(obj,var), ldecvars);
        
        vars = ldecvars(initials);
    end 
    
    function [tf,type] = hasvariable(obj,var,type)
        % Check if variable has been registered (as |type|).
        if nargin > 2
            tf = isfield(obj.(type), var);
        elseif isfield(obj.decvars, var)
            tf = true;
            type = 'decvars';
        elseif isfield(obj.subvars, var)
            tf = true;
            type = 'subvars';
        else
            tf = false;
            type = '';
        end
    end
    
    function tf = isscalar(obj,var)
        % Check if variable is scalar.
        
        if ischar(var)
            var = obj.decvars.(var);
        end
        
        tf = all(var.sz == 1) && isempty(var.z);
    end
    
    function N = numvariables(obj,type)
        % Number of variables of |type|.
        if nargin < 2
            N = numvariables(obj,'decvars') + numvariables(obj,'subvars');
        elseif strcmp(type,'scalar')
            N = sum(structfun(@(p) isscalar(obj,p), obj.decvars));
        elseif strcmp(type,'initial')
            N = sum(structfun(@(p) hasinitial(obj,p), obj.decvars));
        else
            N = length(fieldnames(obj.(type)));
        end
    end
    
    function N = numconstraints(obj,linear)
        % Number of constraints.
        if nargin < 2
            N = length(obj.soscons);
        elseif linear
            N = sum(arrayfun(@(c) isempty(c.bvar), obj.soscons));
        else
            N = numconstraints(obj) - numconstraints(obj,~linear);
        end
    end
end

end