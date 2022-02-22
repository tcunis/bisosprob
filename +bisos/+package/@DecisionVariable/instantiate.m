function [sosc,p] = instantiate(obj,sosc)
% Instantiate a decision variable |var| against SOS constraints.
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:tcunis@umich.edu>
% * Created:    2020-03-31
% * Changed:    2021-06-25
%
%%

sz = size(obj);
    
switch obj.type
    case 'poly'
        [sosc,p] = polymdecvar(sosc,obj.z,sz);
        
    case 'sos'
        [sosc,p] = sosmdecvar(sosc,obj.z,sz);
        
    case 'sym'
        [sosc,p] = symdecvar(sosc,sz(1));
        
    otherwise
        [sosc,p] = decvar(sosc,sz);
end

end
