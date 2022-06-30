function p = get2degree(prob, V)
    [V1,R1] = poly2basis(V, monomials(prob.x, 2));
    p = R1'*V1;
end