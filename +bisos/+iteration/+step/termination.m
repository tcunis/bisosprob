classdef termination < bisos.iteration.Step
   
properties
    type = 'termination';
    varout = [];
    varin;
    data_prev = true;

    operator;
    
    % Structures with info about condtion 
    prev = struct('fhan', @(x) x, 'vars', []);
    curr = struct('fhan', @(x) x, 'vars', []);
end

methods
    function step = termination(~, previous, current, op, varargin)
        % setup termination rule
        
        step.curr = step.setup2struct(step.curr, current);
        step.varin = step.curr.vars;
        step.prev = step.setup2struct(step.prev, previous);
        
        % save operator (maybe I should process it for any kind that 
        % may appear)
        
        switch (op)
        case {'>=', 'ge'} 
           step.operator = @ge; 
        case {'<=', 'le'}
           step.operator = @le; 
        case {'<', 'lt'}
           step.operator = @lt; 
        case {'>', 'gt'}
           step.operator = @gt;  
        case {'==', 'eq'}
           step.operator = @eq;  
        case {op, '~=', 'ne'}
           step.operator = @ne;
        otherwise
           error('Operator "%s" not valid.', op)
        end
    end
    
    function [sol,info,stop] = run(step,prob,info,sol,symbols,assigns,options)
        % Run objective step.
        stop = false;

        if info.iter==1
           return 
        end
        
        % Prepare previous term for condition evaluation

        value1 = step.calcfhan(info.solutions(info.iter -1), step.prev); 

        % Prepare current term for condition evaluation
            
        value2 = step.calcfhan(sol, step.curr);

        if step.operator(value1, value2)
            info.converged = true;
        end
    end
end

methods(Static)
    function value = calcfhan(sol, sstruct) 
        % sol: solutions that are accessed 
        % sstruct: state struture, it can be either previous or current
        % state

        % preallocate auxiliary variable 'v'
        v = cell(1,length(sstruct.vars));

        for i=1:length(sstruct.vars)
            if isfield(sol, sstruct.vars{i})
                v{i} = double(sol.(sstruct.vars{i}));
            else
                error('Non existance of variable in solutions.');
            end
        end
        value = sstruct.fhan(v{:});
    end

    function  defstruct = setup2struct(defstruct, cdef)

        if length(cdef)>1 
            if isa(cdef{1}, "function_handle")
                defstruct.fhan = cdef{1};
                
            % Check coherence between the number of inputs defined in 
            % functions handle and the number of inputs given
                if nargin(defstruct.fhan) ~= (length(cdef)-1)
                    error('Inconsistency between function handle and number of input variables.');
                end
                
                % save variables name in defstruct
                for i=2:length(cdef)
                    % verify if input data type os 'char'
                    if ~ischar(cdef{i})
                        error('error in variables type.');
                    else
                        defstruct.vars{end+1} = cdef{i};
                    end
                end
            else
                error('No function handle is given.')
            end
        elseif ~isempty(cdef)

            if ~ischar(cdef{:})
                error('error in variable type.');
            else
                defstruct.vars = cdef;
            end
        % in case no input is given
        else
            error('Some input variable is empty.')
        end
    end
end


methods (Access=protected)
    function str = varout2str(~)
        % Overriding bisos.iteration.Step#varout2str
        str = 'termrule';
    end
end

end