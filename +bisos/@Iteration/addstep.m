function obj = addstep(obj,type,lvar,objective,ovar,excl)
% Register a new step in the iteration scheme.
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:tcunis@umich.edu>
% * Created:    2020-03-28
% * Changed:    2020-03-30
%
%%

if nargin < 4
    objective = [];
    ovar = [];
    excl = [];
elseif nargin < 6
    excl = [];
end

cellfun(@(v) assert(hasvariable(obj.prob,v), 'Unknown variable ''%s''.', v), [lvar ovar]);

% handle bisection objective
if strcmp(type,'bisect')
    assert(~isempty(objective), 'Cannot bisect with empty objective.');
    assert(length(ovar) < 2, 'Can only bisect along a single variable.');
    assert(isscalar(obj.prob, ovar{:}), 'Can only bisect along scalar variable.');

    p = getvariable(obj.prob, ovar);
    assert(isequal(objective,p) || isequal(objective,-p), 'Objective must be ''+%1$s'' or ''-%1$s''.', ovar{:});

    % variables solved by bisection
    bvar = ovar;
else
    bvar = {};
end

% number of existing steps
N = length(obj.steps);

step = newstep(obj,type,objective);
step.lvar = lvar;
step.ovar = ovar;

% get constraints and variables involved
cidx = cellfun(@(var) getconstraints(obj.prob,var), [lvar ovar], 'UniformOutput', false);
cxcl = cellfun(@(var) getconstraints(obj.prob,var), [excl {}], 'UniformOutput', false);
cidx = setdiff([cidx{:}], [cxcl{:}]);

step.cidx = unique(cidx);

cons = obj.prob.soscons(step.cidx);

% check that constraints are linear in the decision variables
arrayfun(@(i,c) assert(length(intersect(c.bvar,lvar)) <= 1, 'Constraint #%d is bilinear in the step variables.', i), step.cidx', cons);

% variables solved for
solvedfor = [lvar bvar];

% variables involved in constraints & objective
involved = unique([cons.lvar cons.bvar ovar]);

% substituted variables
subinvld = intersect(involved,getvariables(obj.prob,'subvars'));

% linear variables & arguments of substituted variables
sublvar = cellfun(@(sub) obj.prob.subvars.(sub).lvar, subinvld, 'UniformOutput', false);
subargs = cellfun(@(sub) obj.prob.subvars.(sub).args, subinvld, 'UniformOutput', false);
sublvar = [sublvar{:}];
subargs = [subargs{:}];

% linear variables in involved substituted variables are already involved
issolvbl = cellfun(@(sub) all(ismember(obj.prob.subvars.(sub).lvar, involved)), subinvld);
subslvbl = subinvld(issolvbl);

%TODO: determine variables that can be included in this step
%         % list of constraints for each involved variable
%         augmcidx = cellfun(@(var) getconstraints(obj.prob,var), involved, 'UniformOutput', false);
%         augmcons = cellfun(@(idx) obj.prob.soscons(idx), augmcidx, 'UniformOutput', false);
%         % determine involved variables which can be solved for
%         issolvbl = cellfun(@(v,c) isempty(setdiff([c.bvar], [{v} solvedfor])), involved, augmcons);
%         % solvable variables don't have constraints outside step
solvable = []; %involved(issolvbl);

% input variables are all variables involved in the constraints and linear
% variables of subsitutes, yet not solved for or solvable in this step,
% as well as nonlinear arguments to subsitutes (never solvable)
step.varin  = unique([subargs, setdiff(involved, [solvedfor subslvbl solvable])]);

% output variables are all variables involved but not input
step.varout = setdiff(involved, step.varin);
%         step.varout = setdiff([lvar cons.lvar cons.bvar], step.varin);

% substitute variables in this step
step.subnames = subinvld;

% update step graph
nodes = 1:N;
% determine edge to and fro new step
I = arrayfun(@(si) ~isempty(intersect(si.varout,step.varin)), obj.steps);
J = arrayfun(@(sj) ~isempty(intersect(step.varout,sj.varin)), obj.steps);

obj.stepgraph = addedge(obj.stepgraph, nodes(I), N+1);
obj.stepgraph = addedge(obj.stepgraph, N+1, nodes(J));

obj.steps(N+1) = step;

end
