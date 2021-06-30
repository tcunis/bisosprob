classdef bisosprob
% Bilinear sum-of-squares problem definition.
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:tcunis@umich.edu>
% * Created:    2020-03-26
% * Changed:    2020-06-28
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

properties (Access=private,Dependent)
    variables;
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

    function [obj,a] = decvar(obj,vid,varargin)
        % Register a new scalar decision variable |var|.
        
        [obj,a] = obj.addmdecvar(vid,1,'',[],varargin{:});
        
        %TODO: set min/max 
    end
    
    function [obj,p] = polydecvar(obj,vid,z,varargin)
        % Register a new polynomial decision variable |var| with vector of
        % monomials z and optional initial assignment p0.
        
        [obj,p] = obj.addmdecvar(vid,1,'poly',z,varargin{:});
    end
    
    function [obj,s] = sosdecvar(obj,vid,z,varargin)
        % Register a new sum-of-squares decision variable |var| with vector
        % of monomials z and optional initial assignment p0.
        
        [obj,s] = obj.addmdecvar(vid,1,'sos',z,varargin{:});
    end
    
    function [obj,q] = substitute(obj,vid,f,varargin)
        % Register a new subsituting variable |var| with function handle
        % and (linear) arguments.
        
        if isdouble(varargin{end})
            sz = varargin{end};
            varargin = varargin(1:end-1);
        else
            % determine size
            args = cellfun(@(id) getsymbol(obj,id), varargin, 'UniformOutput', false);
            sz = size(f(args{:}));
        end
        
        [obj,q] = obj.addsubsvar(vid,sz,f,varargin{:});
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
    
    function obj = setinitial(obj,vid,p0)
        % Set an initial guess for a registered decision variable.
        var = getvariable(obj,vid,'decvars');
        
        var.initial = p0;
        obj.variables = var;
    end
    
    function obj = setobjective(obj,objective,lvar)
        % Set the objective function.
        
        obj.objective = struct('obj', objective, 'lvar', []);
        obj.objective.lvar = lvar;
    end
end

methods (Access=private)
    %% Private methods
    function [obj,p] = addmdecvar(obj,vid,sz,type,varargin)
        % Register a new decision variable.
        [newvar,p] = bisos.package.DecisionVariable(obj.sosf,vid,type,sz,varargin{:});
        
        obj.variables = newvar;
    end
    
    function [obj,q] = addsubsvar(obj,vid,sz,f,varargin)
        % Register a new subsidiary variable.
        [newvar,q] = bisos.package.SubsidiaryVariable(obj.sosf,vid,sz,f,varargin{:});
        
        for p=newvar.varin
            var = obj.getvariable(p, 'decvars');
            
            var.subsidiaries = vid;
            obj.variables = var;
        end
        
        obj.variables = newvar;
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
            var = obj.getvariable(p);
            
            var.constraints = N+1;
            obj.variables = var;
        end
    end
end

methods
    %% Package interface
    sosc = constraint(obj,sosc,cidx,varargin);
    d = evalobj(obj,varargin);
    
    function [sosc,p] = instantiate(obj,sosc,vid,varargin)
        % Instantiate decision variable.
        var = getvariable(obj,vid,'decvars');
        
        [sosc,p] = instantiate(var,sosc,varargin{:});
    end
    
    function [sosc,p] = evaluate(obj,sosc,vid,varargin)
        % Evaluate subsidiary variable.
        var = getvariable(obj,vid,'subvars');
        
        [sosc,p] = evaluate(var,sosc,varargin{:});
    end

    
    %% Getter functions
    cidx = getconstraints(obj,vid,varargin);
    
    function p = getsymbol(obj,vid)
        % Return polynomial variable object.
        var = getvariable(obj,vid);

        p = var.poly;
    end
    
    function var = getvariable(obj,vid,varargin)
        % Return variable of |type|. Throws error if no variable exists.
        [tf,type] = hasvariable(obj,vid,varargin{:});
        
        if iscell(vid), vid = vid{:}; end
        if ~tf, throwAsCaller(bisos.exception.NoSuchVariable(vid,type)); end
        
        var = obj.(type).(vid);
    end
    
    function vids = getvariables(obj,type)
        % Return list of variables of |type|.
        if nargin < 2
            vids = [getvariables(obj,'decvars'), getvariables(obj,'subvars')];
        else
            vids = fieldnames(obj.(type))';
        end
    end
    
    function [tf,p0] = hasinitial(obj,vid)
        % Check if variable has initial value set.
        var = getvariable(obj,vid,'decvars');

        [tf,p0] = var.hasinitial;
    end
    
    function tf = hasobjective(obj)
        % Check if objective has been set.
        tf = ~isempty(obj.objective);
    end
    
    function [tf,type] = hasvariable(obj,vid,type)
        % Check if variable has been registered (as |type|).
        if nargin > 2
            tf = isfield(obj.(type), vid);
        elseif isfield(obj.decvars, vid)
            tf = true;
            type = 'decvars';
        elseif isfield(obj.subvars, vid)
            tf = true;
            type = 'subvars';
        else
            tf = false;
            type = '';
        end
    end
    
    function vids = haveinitials(obj)
        % Return list of variables with initial values.
        ldecvars = getvariables(obj,'decvars');
        initials = cellfun(@(var) hasinitial(obj,var), ldecvars);
        
        vids = ldecvars(initials);
    end 
    
    function tf = isscalar(obj,vid)
        % Check if decision variable is scalar.
        var = getvariable(obj,vid,'decvars');

        tf = isscalar(var);
    end
    
    function N = numvariables(obj,type)
        % Number of variables of |type|.
        if nargin < 2
            N = numvariables(obj,'decvars') + numvariables(obj,'subvars');
        elseif strcmp(type,'scalar')
            N = sum(structfun(@(p) isscalar(obj,p), obj.decvars));
        elseif strcmp(type,'initial')
            N = sum(structfun(@(p) hasinitial(obj,p), obj.decvars));
        elseif isstruct(obj.(type))
            N = length(fieldnames(obj.(type)));
        else
            N = 0;
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
    
    function obj = set.variables(obj,var)
        % Append variable.
        type = var.category;
        vid = var.id;
        obj.(type).(vid) = var;
    end
end

end