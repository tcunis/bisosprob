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

nodes = cell(length(obj.steps),1);

c = @(s) s(1:end-1);

% add node for each step
for i=1:length(obj.steps)
    step = obj.steps(i);
    
    if strcmp(step.type,'init')
        varin = 'init';
    else
        varin = c(sprintf('%s,',step.varin{:}));
    end
    if strcmp(step.type,'obj')
        varout = 'obj';
    else
        varout = c(sprintf('%s,',step.varout{:}));
    end
    
    nodes{i} = sprintf('%s -> %s', varin, varout);
end

% dummy nodes
if numnodes(G) > length(nodes)
    nodes{end+1:numnodes(G)} = '';
end

G.Nodes.Name = nodes;

end
    
