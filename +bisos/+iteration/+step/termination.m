classdef termination < bisos.iteration.Step
   
properties
    type = 'termination';
    varout = [];
    varin;
    data_prev = true;
    
    % save function handles and variables in play (maybe a struct would be nice)
    operator;
    
    fhan1; 
    vars1; % previous variables
    
    fhan2;
    vars2; % current variables
    
    
    
end

methods
    function step = termination(~, previous, current, op, varargin)
        % setup termination rule
        
        % get variabled needed as input in a certain cycle and save
        % function handles and other variables needed
        if length(current)==1
            % in case NO function handle is defined
            for i = 1:length(current)
                step.varin{length(step.varin)+1}=current{i};
            end
            step.vars2 = current;
        else
            % in case some function handle is defined
            for i = 1:length(current{2})
                step.varin{length(step.varin)+1}=current{2}{i};
            end
            step.vars2 = current{2};
            step.fhan2 = current{1};
        end
        
        if length(previous)==1
            % in case NO function handle is defined
            step.vars1 = previous;
        else
            % in case some function handle is defined
            step.vars1 = previous{2};
            step.fhan1 = previous{1};
        end
        
        
        % save operator (maybe I should process it for any kind that 
        % may appear)
        
        if strcmp(op, '>=') || strcmp(op, 'ge') 
           step.operator = @ge; 
        elseif strcmp(op, '<=') || strcmp(op, 'le')
           step.operator = @le; 
        elseif strcmp(op, '<') || strcmp(op, 'lt')
           step.operator = @lt; 
        elseif strcmp(op, '>') || strcmp(op, 'gt')
           step.operator = @gt;  
        elseif strcmp(op, '==') || strcmp(op, 'eq')
           step.operator = @eq;  
        elseif strcmp(op, '~=') || strcmp(op, 'ne')
           step.operator = @ne;    
        end
        
        assert(~isempty(step.operator), 'Operator not valid.');
        

    end
    
    function [sol,info,stop] = run(step,prob,info,sol,symbols,assigns,options)
        % Run objective step.
        
        if info.iter==1
           stop = false;
           return 
        end
        
        A = double(info.solutions(info.iter -1).(step.vars2{1}));
        B = double(sol.(step.vars1{1}));
        if step.operator(A,B)
            info.converged = true;
        end
        
        stop = false;
    end
    
    function Volume = poly_diff(step, prob, diff)
        
        for i = 1:length(prob.x)
           diff = int(diff, prob.x(i), step.domain);  
        end
        
        Volume = double(diff)/(step.domain(2)-step.domain(1))^length(prob.x);
        
    end
    
end

methods (Access=protected)
    function str = varout2str(~)
        % Overriding bisos.iteration.Step#varout2str
        str = 'term\_rule';
    end
end

end