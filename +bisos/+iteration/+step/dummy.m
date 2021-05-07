classdef dummy < bisos.iteration.Step
    
properties
    type = 'dummy';
    varin = [];
    varout = [];
end

methods
    function [sol,iter,stop] = run(~,~,iter,sol,varargin)
        % nothing to do
        stop = false;
    end
    
    function str = tostr(~)
        % Overriding bisos.iteration.Step#tostr
        str = '';
    end
end

end