function p = get2degree(V, varargin)

    assert(~isempty(varargin), "Error in function handle in tranfer step");

    x=varargin;
    
    [V1,R1] = poly2basis(V, monomials(x{1}, 2));
    p = R1'*V1;
end