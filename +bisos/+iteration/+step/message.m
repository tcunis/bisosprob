classdef message < bisos.iteration.Step
    
properties
    type = 'message';
    varin;
    varout = [];

    fmt;
    lvl;
end

methods
    function step = message(~,fmt,vars,lvl)
        % New message step.
        if nargin < 4
            lvl = 'step';
        end
        
        step.varin = vars;
        step.fmt = fmt;
        step.lvl = lvl;
    end
    
    function [sol,iter,stop] = run(step,~,iter,sol,~,~,options)
        % Run message step.
        args = cellfun(@(var) double(sol.(var)), step.varin, 'UniformOutput', false);
        
        printf(options,step.lvl,step.fmt,args{:});
        
        stop = false;
    end
end

methods (Access=protected)
    function str = varout2str(~)
        % Overriding bisos.iteration.Step#varout2str
        str = 'message';
    end
end

end