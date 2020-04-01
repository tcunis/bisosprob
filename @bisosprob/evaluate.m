function [sosc,p] = evaluate(obj,sosc,var,~,assigns)
% Evaluate a derived variable |var|.
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:tcunis@umich.edu>
% * Created:    2020-03-31
% * Changed:    2020-03-31
%
%%

assert(hasvariable(obj,var,'subvars'), 'Unknown substituted variable ''%s''.', var{:});

if iscell(var)
    var = var{:};
end

svar = obj.subvars.(var);

lvar = cellfun(@(var) assigns.(var), [svar.lvar {}], 'UniformOutput', false);
args = cellfun(@(arg) assigns.(arg), [svar.args {}], 'UniformOutput', false);

p = svar.fhan(lvar{:},args{:});

end
