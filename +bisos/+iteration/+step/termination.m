classdef termination < bisos.iteration.Step
   
properties
    type = 'termination';
    varout = [];
    varin;

    operator;
    
    % Structures with info about condition 
    prev = struct('fhan', @(x) x, 'vars', []);
    curr = struct('fhan', @(x) x, 'vars', []);
end

methods
    function step = termination(prob, previous, current, op, varargin)
        % setup termination rule
        
        step.curr = step.setup2struct(step.curr, current);
        step.prev = step.setup2struct(step.prev, previous);

        step.varin = union(step.curr.vars, step.prev.vars);

        cellfun(@(v) assert(hasvariable(prob,v),'Unknown variable ''%s''.',...
            v), [step.curr.vars step.prev.vars]);

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
    
    function [sol,info,stop] = run(step,~,info,sol,varargin)
        % Run objective step.
        stop = false;

        if info.iter > 1
            stepinfo = getinfo(step,info);
        
            % Prepare current term for condition evaluation    
            value2 = step.calcfhan(sol, step.curr);
        
            % Get previous term for condition evaluation
            value1 = stepinfo.value;

            if step.operator(value1, value2)
                info.converged = true;
            end
        end
        
        % Store 'previous' term for next iteration
        stepinfo.value = step.calcfhan(sol, step.prev);
        
        info = setinfo(step,info,stepinfo);
    end
end

methods (Static, Access=private)
    function value = calcfhan(sol, sstruct) 
        % sol: solutions that are accessed 
        % sstruct: state struture, it can be either previous or current
        % state

        % preallocate auxiliary variable 'v'
        v = cell(1,length(sstruct.vars));
        for i=1:length(sstruct.vars)
            v{i} = double(sol.(sstruct.vars{i}));
        end

        value = sstruct.fhan(v{:});
    end

    function  defstruct = setup2struct(defstruct, cdef)

        assert(~isempty(cdef), 'No input variables given.')
        
        if length(cdef)>1
            assert(isa(cdef{1}, "function_handle"),...
                'No function handle but more than one variable given.')
            
            defstruct.fhan = cdef{1};
                
            % Check coherence between the number of inputs defined in 
            % functions handle and the number of inputs given
            if nargin(defstruct.fhan) ~= (length(cdef)-1)
                error('Wrong number of inputs (expected: %d, given: %d).',...
                    nargin(defstruct.fhan), length(cdef)-1);
            end
                
            % save variables name in defstruct
            defstruct.vars = cell(1,length(cdef)-1);
            for i=2:length(cdef)
                defstruct.vars{i-1} = cdef{i};
            end
        else
            defstruct.vars = cdef;
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