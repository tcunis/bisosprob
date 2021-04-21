function G = graph(obj,G)
% Return a graph structure representing the iteration scheme.
%
% Here, the vertices represent the steps and directional edges represent
% flow of variables.
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:tcunis@umich.edu>
% * Created:    2020-03-30
% * Changed:    2020-03-31
%
%%

if nargin < 2
    G = obj.stepgraph;
end

% add dummy steps if necessary
obj = complete(obj,G);

nodes = cellfun(@(step) tostr(step), obj.steps', 'UniformOutput', false);

G.Nodes.Name = nodes;

end
    
