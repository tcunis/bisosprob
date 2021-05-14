classdef message < bisos.iteration.OutputStep
    
properties
    fmt;
    lvl;
end

methods
    function step = message(~,fmt,vars,lvl)
        % New message step.
        if nargin < 4
            lvl = 'step';
        end
        
        step@bisos.iteration.OutputStep('message',vars);
        
        step.fmt = fmt;
        step.lvl = lvl;
    end    
end

methods (Access=protected)
    function stop = run_output(step,~,options,varargin)
        % Run message step.
        args = cellfun(@(p) double(p), varargin, 'UniformOutput', false);
        
        printf(options,step.lvl,step.fmt,args{:});
        
        stop = false;
    end
end

end