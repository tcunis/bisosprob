classdef dummy < bisos.iteration.Step
    
properties
    type = 'dummy';
    varin = [];
    varout = [];
end

methods
    function [sol,assigns,iter,stop] = run(~,~,iter,sol,~,assigns,varargin)
        % nothing to do
        stop = false;
    end
end

end