classdef Options < bisos.package.Options
% Options for sequential sum-of-squares solvers.
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:torbjoern.cunis@ifr.uni-stuttgart.de>
% * Created:    2022-04-01
% * Changed:    2022-04-01
%
%%

properties
    % feasibility checks
    checkfeas = false;
    feastol = 1e-6;
    
    % termination tolerance
    abstol = 1e-6;
    reltol = 1e-6;
end

methods
    function obj = Options(varargin)
        % New options instance.
        obj@bisos.package.Options(varargin{:});
    end
end

end