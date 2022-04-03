classdef Options
% Options for iterative methods.
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
    SAVESOL = struct('off',0,'result',1,'step',3);
end

properties
    Niter = 10;
    display = 0;
    fid = 1;
    savesol = 0;
    logdir = '.';
    logprefix = '';
    logname = '';
    
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
    
    function obj = set.savesol(obj,value)
        % Set solution saving configuration.
        assert(ischar(value), 'Displaying option must be character array.');
        assert(isfield(obj.SAVESOL,value), 'Unknown saving option ''%s''.', value);
        
        obj.savesol = obj.SAVESOL.(value);
    end
    
    function obj = set.fid(obj,value)
        % Set output stream for displaying.
        assert(isnumeric(value), 'File ID must be numeric.');
        assert(value > 0, 'Unknown file ID %d.', value);
        
        obj.fid = value;
    end
    
    function obj = set.logdir(obj,value)
        % Set file directory for log.
        assert(ischar(value),'Log directory must be string.');
        
        obj.logdir = value;
    end
    
    function obj = set.logprefix(obj,value)
        % Set file name prefix for log.
        assert(ischar(value),'Log prefix must be string.');
        
        obj.logprefix = value;
    end 
    
    function obj = set.logname(obj,value)
        % Set file name for log.
        assert(ischar(value),'Log name must be string.');
        
        obj.logname = value;
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
    
    %% File storage
    function writetofile(obj,lvl,sol,fmt,varargin)
        % Write solution to file if level permits.
        if ~isfield(obj.DISPLAY,lvl)
            % default level
            varargin = [{fmt} varargin];
            fmt = sol;
            sol = lvl;
            lvl = obj.SAVESOL.step;
        else
            lvl = obj.SAVESOL.(lvl);
        end
        
        if lvl <= obj.savesol
            save(sprintf([obj.logdir '/' obj.logprefix fmt],varargin{:}), '-struct', 'sol');
        end
    end
    
    function sol = readfile(obj,fname)
        % Read solution from file.
        
        sol = load([obj.logdir '/' obj.logprefix fname], '-mat');
    end
    
    function obj = preparelog(obj)
        % Prepare for logs.
        if strcmp(obj.logdir, '.')
            % nothing to do
        elseif ~exist(obj.logdir,'file')
            [success,info] = mkdir(obj.logdir);
            if isempty(info)
                % nothing to do
            elseif success
                warning(info)
            else
                error(info)
            end
        else
            delete([obj.logdir '/*.mat']);
        end
        
        if ~isempty(obj.logname)
            obj.fid = fopen([obj.logdir '/' obj.logprefix obj.logname],'w');
        end
    end
    
    function finishlog(obj,stop)
        % Finalize logs.
        if obj.fid > 2
            printf(obj,'off','Return %d',stop);
            fclose(obj.fid);
        end
    end
end

end