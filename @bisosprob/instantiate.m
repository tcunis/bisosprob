function [sosc,p] = instantiate(obj,sosc,var)
% Instantiate a decision variable |var| against SOS constraints.
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:tcunis@umich.edu>
% * Created:    2020-03-31
% * Changed:    2020-03-31
%
%%

assert(hasvariable(obj,var,'decvars'), 'Unknown variable ''%ss''.', var{:});

if iscell(var)
    var = var{:};
end

dvar = obj.decvars.(var);

switch dvar.type
    case 'poly'
        [sosc,p] = polymdecvar(sosc,dvar.z,dvar.sz);
        
    case 'sos'
        [sosc,p] = sosmdecvar(sosc,dvar.z,dvar.sz);
        
    case 'sym'
        [sosc,p] = symdecvar(sosc,dvar.z,dvar.sz(1));
        
    otherwise
        [sosc,p] = decvar(sosc,dvar.sz);
end

end
