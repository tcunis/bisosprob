classdef Options < bisos.package.Options
% Options for bilinear sum-of-squares iteration.
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:torbjoern.cunis@ifr.uni-stuttgart.de>
% * Created:    2022-04-01
% * Changed:    2022-04-01
%
%%

properties (Constant)
    ROUTING = struct('auto',0,'user',1);
end

properties
    routing = 0;
end

methods
    function obj = Options(varargin)
        % New options instance.
        obj@bisos.package.Options(varargin{:});
    end
    
    %% Setter methods
    function obj = set.routing(obj,value)
        % Set auto routing configuration.
        assert(ischar(value), 'Routing option must be character array.');
        assert(isfield(obj.ROUTING,value), 'Unknown routing option ''%s''.', value);
        
        obj.routing = obj.ROUTING.(value);
    end
    
    %% Routing
    function tf = isrouting(obj,value)
        % Check routing option.
        if isfield(obj.ROUTING,value)
            value = obj.ROUTING.(value);
        end
        
        tf = ( obj.routing == value );
    end
end

end