function obj = sosupdate(obj, varargin)
    
    if isempty(varargin)
        return
    else
        % get number of polynomials to update
        lspoly = length(varargin); 
        spoly = polynomial(zeros(lspoly,1));
        for i=1:lspoly
            spoly(i) = varargin{i};
        end
    end
    
    % get prob structure to get information
    prob = obj.prob;
    
    % get decision variables and subsidiary decision variables
    auxdec = prob.decvars;
    auxsub = prob.subvars;

    % get all variables from constraints
    vars = prob.soscons.variables;
    subfields = fieldnames(auxsub);
    decfields = fieldnames(auxdec);
    s = 0;
    for i = vars
        if ismember(i, decfields)
            s = s + length(auxdec.(i{:}).poly.varname);
        end
        if ismember(i, subfields)
            s = s + length(auxsub.(i{:}).poly.varname);
        end

    end
    s = s-lspoly; 

    id = cell(s,1); 
    poly = cell(s,1); 
    z = cell(s,1);
    
    % for each variables get required info
    k = 1;
    for i=vars
        if ~contains(i, spoly.varname) % i don't want spoly
            % verifies if that variable exists in decvars
            if isfield(auxdec, i)
                id{k} = auxdec.(i{:}).id;
                poly{k} = auxdec.(i{:}).poly;
                if isempty(auxdec.(i{:}).pol0)
                    z{k} = sum(auxdec.(i{:}).z);
                else
                    z{k} = auxdec.(i{:}).pol0;
                end
                k = k+1;
            else % otherwise it is a subvariable
                
                a=cell(1,length(auxsub.(i{:}).varin));
                for j=1:length(auxsub.(i{:}).varin)
                    if isempty(auxdec.(auxsub.(i{:}).varin{j}).pol0)
                        a{j} = sum(auxdec.(auxsub.(i{:}).varin{j}).z);
                    else
                        a{j} = auxdec.(auxsub.(i{:}).varin{j}).pol0;
                    end
                end

                out = auxsub.(i{:}).fhan(a{:});
                for j=1:length(auxsub.(i{:}).poly)
                    poly{k} = auxsub.(i{:}).poly(j);
                    z{k}=out(j);
                    id{k} = auxsub.(i{:}).poly.varname(j);
                    k=k+1;
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

    % pre process to only obtain constraints containing the variables of
    % the step
    pcons.lhs = prob.soscons.lhs;
    pcons.rhs = prob.soscons.rhs;


    % loop over each constraint and in each
    
    [g0, g1, h] = collect(pcons.lhs + pcons.rhs, [prob.x; [poly{:}]']);
    
    for i=1:length(id)
        g0 = subs(g0, poly{i}, z{i});
        g1 = subs(g1, poly{i}, z{i});
    end
    
    % try to avoid inner loops
    sdeg=zeros(1,lspoly);

    [p1, p2]= meshgrid(1:length(g1), 1:length(sdeg));
    pind = [p1(:), p2(:)];
    pind = num2cell(pind)';

    for i=pind
        inddeg = g0(i{1}).maxdeg;
        if not(double(g1(i{:}).coefficient==0))
            if sdeg(i{2}) < inddeg - g1(i{:}).maxdeg
                sdeg(i{2}) = inddeg - g1(i{:}).maxdeg +1;
            end
        end
    end

    % assign new monomials (verify type)
    for i=1:lspoly
        if strcmp(prob.decvars.(spoly(i).varname{:}).type, 'sos')
            if sdeg(i)==0
                sdeg(i)=2;
            end
           prob.decvars.(spoly.varname{i}).z = monomials(prob.x,0:ceil(sdeg(i)/2));
        else    
           prob.decvars.(spoly.varname{i}).z = monomials(prob.x,0:sdeg(i));
       end
    end

    obj.prob = prob;
end