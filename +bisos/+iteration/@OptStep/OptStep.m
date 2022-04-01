classdef (Abstract) OptStep < bisos.iteration.Step
   
properties
    type;
    varin;
    varout;
    
    objective;
    
    lvar;
    ovar;
    cidx;

    subnames;
end

methods (Abstract)
    [stepsol,info] = solve(obj,sosc,objective,info,sosoptions,varargin);
    [sosc,assigns] = prepare(obj,prob,sosc,symbols,assigns);
end

methods
    function obj = OptStep(prob,type,lvar,bvar,objective,ovar,excl)
        % New optimization step.
        obj.type = type;
        
        if nargin < 5
            objective = [];
            bvar = [];
            ovar = [];
            excl = [];
        elseif nargin < 7
            excl = [];
        end

        cellfun(@(v) assert(hasvariable(prob,v), 'Unknown variable ''%s''.', v), [lvar bvar ovar excl]);
        
        obj.objective = objective;
        
        obj.lvar = lvar;
        obj.ovar = ovar;

        % get constraints and variables involved
        cidx = cellfun(@(var) getconstraints(prob,var), [lvar ovar], 'UniformOutput', false);
        cxcl = cellfun(@(var) getconstraints(prob,var), [excl {}], 'UniformOutput', false);
        cidx = setdiff([cidx{:}], [cxcl{:}]);

        obj.cidx = unique(cidx);

        cons = prob.soscons(obj.cidx);

        % check that constraints are linear in the decision variables
        arrayfun(@(c,i) assert(length(intersect(c.bvar,lvar)) <= 1, 'Constraint #%d is bilinear in the step variables.', i), cons, obj.cidx);

        % variables solved for
        solvedfor = [lvar bvar];

        % variables involved in constraints & objective
        involved = unique([cons.variables ovar]);

        % substituted variables
        subinvld = intersect(involved,getvariables(prob,'subvars'));

        % linear variables & arguments of substituted variables
        sublvar = cellfun(@(sub) prob.subvars.(sub).lvar, subinvld, 'UniformOutput', false);
        subargs = cellfun(@(sub) prob.subvars.(sub).args, subinvld, 'UniformOutput', false);
        sublvar = unique([sublvar{:}]);
        subargs = unique([subargs{:}]);

        % linear variables in involved substituted variables are also involved
        involved = unique([involved sublvar]);
        
        % substituted variables of which all linear variables are involved
        % those can be solved for too
        issolvbl = cellfun(@(sub) all(ismember(prob.subvars.(sub).lvar, involved)), subinvld);
        subslvbl = subinvld(issolvbl);

        %TODO: determine variables that can be included in this step
        %         % list of constraints for each involved variable
        %         augmcidx = cellfun(@(var) getconstraints(prob,var), involved, 'UniformOutput', false);
        %         augmcons = cellfun(@(idx) prob.soscons(idx), augmcidx, 'UniformOutput', false);
        %         % determine involved variables which can be solved for
        %         issolvbl = cellfun(@(v,c) isempty(setdiff([c.bvar], [{v} solvedfor])), involved, augmcons);
        %         % solvable variables don't have constraints outside step
        solvable = []; %involved(issolvbl);

        % input variables are all variables involved in the constraints and linear
        % variables of subsitutes, yet not solved for or solvable in this step,
        % as well as nonlinear arguments to subsitutes (never solvable)
        obj.varin  = unique([subargs, setdiff(involved, [solvedfor subslvbl solvable])]);

        % output variables are all variables involved but not input
        obj.varout = setdiff(involved, obj.varin);
        %         step.varout = setdiff([lvar cons.lvar cons.bvar], step.varin);

        % substitute variables in this step
        obj.subnames = subinvld;
    end
    
    function obj = set.varin(obj,value)
        % Set input variables.
        if isempty(value)
            obj.varin = [];
        else
            obj.varin = value;
        end
    end
    
    function obj = set.varout(obj,value)
        % Set output variables.
        if isempty(value)
            obj.varout = [];
        else
            obj.varout = value;
        end
    end
    
    function obj = set.subnames(obj,value)
        % Set substituted variables.
        if isempty(value)
            obj.subnames = [];
        else
            obj.subnames = value;
        end
    end
end

end