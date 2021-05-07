classdef Options
% Options for bilinear sum-of-squares iteration schemes.
%
%% About
%
% * Author:     Torbjoern Cunis
% * Email:      <mailto:tcunis@umich.edu>
% * Created:    2020-03-28
% * Changed:    2020-03-28
%
%%

properties (Constant)
    DISPLAY = struct('off',0,'result',1,'warning',2,'step',3,'debug',4);
    ROUTING = struct('auto',0,'user',1);
end

properties
    Niter = 10;
    display = 0;
    fid = 1;
    routing = 0;
    
    sosoptions;
end

methods
    function obj = Options(sosf,varargin)
        % New options instance.
        
        for i=1:2:length(varargin)
            obj.(varargin{i}) = varargin{i+1};
        end
        
        if isempty(obj.sosoptions)
            obj.sosoptions = newoptions(sosf);
        end
    end
    
    %% Setter methods
    function obj = set.Niter(obj,value)
        % Set number of iterations.
        assert(isnumeric(value) && value > 0, 'Number of iterations must be a positive integer.');
        
        obj.Niter = value;
    end
    
    function obj = set.display(obj,value)
        % Set displaying configuration.
        assert(ischar(value), 'Displaying option must be character array.');
        assert(isfield(obj.DISPLAY,value), 'Unknown displaying option ''%s''.', value);
        
        obj.display = obj.DISPLAY.(value);
    end
    
    function obj = set.routing(obj,value)
        % Set auto routing configuration.
        assert(ischar(value), 'Routing option must be character array.');
        assert(isfield(obj.ROUTING,value), 'Unknown routing option ''%s''.', value);
        
        obj.routing = obj.ROUTING.(value);
    end
    
    function obj = set.fid(obj,value)
        % Set output stream for displaying.
        assert(isnumeric(value), 'File ID must be numeric.');
        assert(~isempty(fopen(value)), 'Unknown file ID %d.', value);
    end
    
    
    %% Displaying
    function nb = printf(obj,lvl,fmt,varargin)
        % Write message to display stream if level permits.
        if ~isfield(obj.DISPLAY,lvl)
            % default level
            varargin = [{fmt} varargin];
            fmt = lvl;
            lvl = obj.DISPLAY.step;
        else
            lvl = obj.DISPLAY.(lvl);
        end
        
        if lvl <= obj.display
            nb = fprintf(obj.fid,fmt,varargin{:});
        else
            nb = 0;
        end
    end
            
end

end