classdef (Abstract) Step
    
properties (Abstract)
    type;
    varin;
    varout;
end        

methods (Abstract)
    [sol,assigns,iter,stop] = run(obj,prob,iter,sol,symbols,assigns,varargin);
end
    
end
