function tf = letol(sosc,A,B,tol)
% Lower-than-or-equal with tolerance.

if isempty(tol)
    expr = 0;
else
    z = grambasis(sosc,B-A);
    expr = tol*(z'*z);
end

tf = le(sosc, A, B + expr);

end
