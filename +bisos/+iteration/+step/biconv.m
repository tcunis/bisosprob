classdef biconv < bisos.iteration.step.bisect
    
properties
    conv;
%     feas;
end
    
methods
    function step = biconv(prob,lvar,objective,ovar,varargin)
        % New biconvex optimization step.
        step@bisos.iteration.step.bisect(prob,lvar,objective,ovar,varargin{:});
        
        import bisos.iteration.step.*
        step.conv = convex(prob,ovar,objective,ovar,varargin{:});
%         step.feas = convex(prob,lvar,[],[],varargin{:});
    end
    
    function [sol,info,stop] = run(step,prob,info,sol,symbols,assigns,options)
        % Overwriting OptStep#run
        tlb = options.sosoptions.minobj;
        tub = options.sosoptions.maxobj;
        
        tol = options.sosoptions.absbistol;
        
        if all(cellfun(@(v) ~isempty(sol.(v)), step.lvar))
            % perform convex subproblem
            [sol,info,stop] = run(step.conv,prob,info,sol,symbols,assigns,options);
            
            if stop, return; end
            
            % solution of convex subproblem
            obj0 = double(bisos.subs(step.objective,symbols,sol,step.ovar));
            
            % bounds for bisection
            tlb = obj0-tol;
            tub = obj0:+tol:tub;
        end
        
        % set lower and upper bounds
        options.sosoptions.minobj = tlb;
        options.sosoptions.maxobj = tub;
        
        % information about convex subproblem
        convsubprob = info.subprob;
        
        % run step as usual
        [sol,info,stop] = run@bisos.iteration.step.bisect(step,prob,info,sol,symbols,assigns,options);
        
        % information about subproblems
        info.subprob = [convsubprob info.subprob];
    end
            
end
    
end 
