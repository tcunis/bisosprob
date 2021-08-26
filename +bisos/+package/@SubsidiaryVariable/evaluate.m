function [sosc,p] = evaluate(obj,sosc,~,assigns)
% Evaluate a subsidiary variable |var|.
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:tcunis@umich.edu>
% * Created:    2020-03-31
% * Changed:    2021-06-28
%
%%

lvar = cellfun(@(var) assigns.(var), [obj.lvar {}], 'UniformOutput', false);
args = cellfun(@(arg) assigns.(arg), [obj.args {}], 'UniformOutput', false);

p = obj.fhan(lvar{:},args{:});

end
