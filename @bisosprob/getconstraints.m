function c = getconstraints(obj,var,caller_id)
% Return indizes of constraints involving a variable.
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:tcunis@umich.edu>
% * Created:    2020-03-31
% * Changed:    2021-06-28
%
%%

[tf,type] = hasvariable(obj,var);
if iscell(var), var = var{:}; end

assert(tf, 'Unknown variable ''%s''.', var);

var = obj.(type).(var);

% avoid infinite loop
if nargin < 3
    caller_id = {};

elseif ismember(var.id,caller_id) ...
        || strcmp(type,'subvars') && any(ismember([var.args {}],caller_id)) % Work-around: don't add nonlinear arguments
    c = [];
    return
end

% also get constraints of parental / derived variables
if strcmp(type,'decvars')
    cs = cellfun(@(sub) getconstraints(obj,sub,[caller_id {var.id}]), [var.subs {}], 'UniformOutput', false);

elseif strcmp(type,'subvars')
    cs = cellfun(@(arg) getconstraints(obj,arg,[caller_id {var.id} var.args]), [var.lvar {}], 'UniformOutput', false);
end

c = unique([var.cidx cs{:}]);

end