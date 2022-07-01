function prob = spolyrenew(prob, spoly)
    
    % get poly property from decvars
    auxdec = prob.decvars;
    auxsub = prob.subvars;
    
    vars = prob.soscons.variables;

    id={}; poly={}; z={};
    
    for i=1:length(vars)
        if ~contains(vars(i), spoly.varname) % i don't want spoly
            % verifies if that variable exists in decvars
            if isfield(auxdec, prob.soscons.variables{i})
                id{end+1} = auxdec.(vars{i}).id;
                poly{end+1} = auxdec.(vars{i}).poly;
                z{end+1} = sum(auxdec.(vars{i}).z);
                
            else % otherwise it is a subvariable
                
                a=cell(1,length(auxsub.(vars{i}).varin));
                for j=1:length(auxsub.(vars{i}).varin)
                    a{j} = sum(auxdec.(auxsub.(vars{i}).varin{j}).z);
                end

                out = auxsub.(vars{i}).fhan(a{:});
                for j=1:length(auxsub.(vars{i}).poly)
                    poly{end + 1} = auxsub.(vars{i}).poly(j);
                    z{end+1}=out(j);
                    id{end + 1} = auxsub.(vars{i}).poly.varname(j);
                end
            end
        end
    end

    % changes to z just in case
    for i=1:length(z)
        if ~isa(z{i}, 'polynomial')
            z{i}=1;
        end
    end
    

    % loop over each constraint and in each
    
    [g0, g1, h] = collect(prob.soscons.lhs + prob.soscons.rhs, [prob.x; [poly{:}]']);
    
    for i=1:length(id)
        g0 = subs(g0, poly{i}, z{i});
        g1 = subs(g1, poly{i}, z{i});
    end
    
    sdeg=zeros(1,length(spoly));
    for i=1:length(g1)
        inddeg = g0(i).maxdeg;
        
        for j=1:length(sdeg)
            if not(double(g1(i,j).coefficient==0))
                if sdeg(j) < inddeg - g1(i,j).maxdeg
                    sdeg(j) = inddeg - g1(i,j).maxdeg;
                end
            end
        end
    end
    

    % assign new monomials
    for i=1:length(spoly)
        if sdeg(i) > 0
            prob.decvars.(spoly.varname{i}).z = monomials(prob.x,1:sdeg(i));
        else
            prob.decvars.(spoly.varname{i}).z = monomials(prob.x,0);
        end
    end

%     if s1deg > 0
%         prob.decvars.s1.z = monomials(prob.x,1:s1deg);
%     else
%         prob.decvars.s1.z = monomials(prob.x,0);
%     end
%     
% 
%     if s2deg > 0
%         prob.decvars.s2.z = monomials(prob.x,1:s2deg);
%     else
%         prob.decvars.s2.z = monomials(prob.x,0);
%     end
    
   
end





















