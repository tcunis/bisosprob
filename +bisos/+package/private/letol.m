function tf = letol(sosc,A,B,tol)
% Lower-than-or-equal with tolerance.

if isempty(tol)
    tol = 0;
end

tf = le(sosc, A, B + tol);

end
