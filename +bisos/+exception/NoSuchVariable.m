classdef NoSuchVariable < MException
% Throw exception if no such variable exists.
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:torbjoern.cunis@uni-stuttgart.de>
% * Created:    2021-06-28
% * Changed:    2021-06-28
%
%%
    
properties
    vartype;
    varid;
end

methods
    function err = NoSuchVariable(vid,type)
        % Variable |vid| does not exist or is not of |type|.
        if nargin < 2, type = ''; end
        
        switch (type)
            case 'decvars', msg = 'Unknown decision variable';
            case 'subvars', msg = 'Unknown substituting variable';
            otherwise, msg = 'Unkown variable';
        end
        
        err@MException('bisos:NoSuchVariable', [msg ' ''%s''.'], vid);
        
        err.vartype = type;
        err.varid = vid;
    end
end

end