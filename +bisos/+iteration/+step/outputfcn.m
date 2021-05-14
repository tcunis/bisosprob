classdef outputfcn < bisos.iteration.OutputStep
    
properties
    fhan;
    args;
end

methods 
    function step = outputfcn(~,fhan,vars,varargin)
        % New output function step.
        step@bisos.iteration.OutputStep('outputfcn',vars);
        
        step.fhan = fhan;
        step.args = varargin;
    end
end

methods (Access=protected)
    function stop = run_output(step,~,~,varargin)
        % Run output function step.
        stop = feval(step.fhan, varargin{:}, step.args{:});
    end
end

end