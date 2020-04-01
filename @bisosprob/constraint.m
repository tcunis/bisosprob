function sosc = constraint(obj,sosc,cidx,symbols,assigns)
% Add constraint(s) #cidx to SOS constraints.
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:tcunis@umich.edu>
% * Created:    2020-03-31
% * Changed:    2020-03-31
%
%%

for ci=cidx
    assert(ci <= length(obj.soscons), 'Constraint index out of bound (%d).', ci);
    
    cons = obj.soscons(ci);
    
    LHS = bisos.subs(cons.lhs,symbols,assigns);
    RHS = bisos.subs(cons.rhs,symbols,assigns);
    
    sosc = cons.cmp(sosc,LHS,RHS);
end

end
