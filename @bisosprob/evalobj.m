function d = evalobj(obj,varargin)
% Evaluate the objective function against a solution.
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:tcunis@umich.edu>
% * Created:    2020-03-31
% * Changed:    2020-03-31
%
%%

d = double(bisos.subs(obj.objective.obj, varargin{:}));

end
