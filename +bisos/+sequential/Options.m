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

properties (Constant)
    CHECKFEAS = struct('off',0,'result',1,'step',2,'warning',3);
end

properties
    % feasibility checks
    checkfeas = 0;
    feastol = 1e-6;
    
    % step length regulation
    stepbnds = [0.1 1];
    
    % termination tolerance
    abstol = 1e-6;
    reltol = 1e-6;
end

methods
    function obj = Options(varargin)
        % New options instance.
        obj@bisos.package.Options(varargin{:});
    end
    
    function obj = set.checkfeas(obj,value)
        % Set feasibility checking.
        assert(ischar(value), 'Feasbilitity check option must be character array.');
        assert(isfield(obj.CHECKFEAS,value), 'Unknown checking option ''%s''.', value);
        
        obj.checkfeas = obj.CHECKFEAS.(value);
    end
    
    %% Feasibility check
    function tf = checkfeasibility(obj,lvl)
        % Return true if feasibility is to checked at this level.
        if nargin < 2
            % default level
            lvl = obj.CHECKFEAS.step;
        elseif ischar(lvl)
            lvl = obj.CHECKFEAS.(lvl);
        end
        
        tf = (lvl <= obj.checkfeas);
    end
    
    function nb = assertfeas(obj,tol,lvl,varargin)
        % Assert feasibility within tolerance.
        nb = 0;
        
        if tol < obj.feastol
            % solution is feasible within tolerance
        elseif ~checkfeasibility(obj,lvl)
            % solution infeasible but ignore
        else
            nb = printf(obj,'warning',varargin{:});
        end
    end
end

end