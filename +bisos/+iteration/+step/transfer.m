classdef transfer < bisos.iteration.Step
   
properties
    type = 'transfer';
    varout = [];
    varin;
    args;
    fun;
end

methods
    function step = transfer(prob, output, fun_handle, input, varargin)
        % New transfer step.
        
        assert(isa(fun_handle, "function_handle"), 'Not a function handle.');

        step.fun = fun_handle; 
        
        step.varin = input;

        assert(length(output)==1, 'Function handle must return exactly one output.');

        step.varout = output;  

        step.args = varargin;

        cellfun(@(v) assert(hasvariable(prob,v),'Unknown variable ''%s''.',...
            v), [step.varin step.varout]);
        
        
    end
    
    function [sol,info,stop] = run(step,prob,info,sol,symbols,assigns,options)
        % Run transfer step.
        
        a = cell(1, length(step.varin));
        for i=1:length(step.varin)
            a{i} = sol.(step.varin{i});
        end

        % set objective
        sol.(step.varout{1}) = step.fun(a{:}, step.args{:});
        
        stop = false;
    end
    
end

methods (Access=protected)

end

end