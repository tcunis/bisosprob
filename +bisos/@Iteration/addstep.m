function obj = addstep(obj,type,varargin)
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

% number of existing steps
N = length(obj.steps);

% create new step
step = newstep(obj,type,obj.prob,varargin{:});

% update step graph
nodes = 1:N;
% determine edge to and fro new step
I = cellfun(@(si) ~isempty(intersect(si.varout,step.varin)), obj.steps);
J = cellfun(@(sj) ~isempty(intersect(step.varout,sj.varin)), obj.steps);

obj.stepgraph = addedge(obj.stepgraph, nodes(I), N+1);
obj.stepgraph = addedge(obj.stepgraph, N+1, nodes(J));

% objective should be last step
obj.steps(N+1) = obj.steps(N); 
obj.steps(N) = {step};

obj.stepgraph = reordernodes(obj.stepgraph,[1:N-1 N+1 N]);

end