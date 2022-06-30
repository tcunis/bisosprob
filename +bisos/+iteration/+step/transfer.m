classdef transfer < bisos.iteration.Step
   
properties
    type = 'transfer';
    varout = [];
    varin;
    fun;
end

methods
    function step = transfer(prob, output, fun_handle, input, varargin)
        % New transfer step.
        
        assert(isa(fun_handle, "function_handle"), 'Not a function handle.');

        step.fun = fun_handle; 
        
        assert(nargin(fun_handle)-1==length(input),...
            'Number of inputs is incorrect %d\nShould be %d', length(input), nargin(fun_handle)-1);

        step.varin = input;

        assert(length(output)==1, 'Not a single output');

        step.varout = output;   

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
        sol.(step.varout{1}) = step.fun(prob, a{:});
        
        stop = false;
    end
    
end

methods (Access=protected)
    %function str = varout2str(~)
        % Overriding bisos.iteration.Step#varout2str
        %str = 'transfer';
    %end
end

end