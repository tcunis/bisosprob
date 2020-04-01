function G = graph(obj)
% Return a graph structure representing the bilinear problem.
%
% Here, the vertices represent the decision variables and the edges
% represent constraints.
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:tcunis@umich.edu>
% * Created:    2020-03-27
% * Changed:    2020-03-28
%
%%

G = graph;

decvarnames = getvariables(obj,'decvars');
subvarnames = getvariables(obj,'subvars');

nodenames = [decvarnames subvarnames];

G = addnode(G, nodenames);

% construct weighted edges between decision variables
for pi = 1:length(nodenames)
    p = nodenames(pi);
    if pi <= length(decvarnames)
        type = 'decvars';
    else
        type = 'subvars';
    end
    var = obj.(type).(p{:});
    
    % handle subsidary variable
    switch (type)
        case 'subvars'
        dep = var.lvar; % parental decision variables
        G = addedge(G,p,dep,NaN);

        case 'decvars'
        dep = var.subs; % derived decision variables
        if ~isempty(var.p0)
            p0 = [p{:} '0'];
            G = addnode(G,p0);
            G = addedge(G,p,p0,0);
        end
    end
    
    % iterate over constraints
    for ci = var.cidx
        con = obj.soscons(ci);
        
        if length([con.lvar con.bvar]) == 1
            % constraint with single variable
            G = addedge(G,p,p,ci);
        else
            % constraint with multiple variables
            for q = [con.lvar con.bvar]
                if strcmp(p,q) || any(strcmp(q,dep))
                    % don't show edges to dependencies
                    continue
                elseif findnode(G,q)
                    % don't show multiple edges
                    idx = findedge(G,p,q);
                    
                    if all(idx) && any(G.Edges.Weight(idx) == ci)
                        continue
                    end
                end
                
                % else:
                G = addedge(G,p,q,ci);
            end
        end
    end
end

% handle objective
if hasobjective(obj)
    pobj = '[obj]';
    G = addnode(G,pobj);
    
    for q = obj.objective.lvar
        G = addedge(G,q,pobj,Inf);
    end
end
    
end

