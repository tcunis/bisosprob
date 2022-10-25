function tf = getol(sosc,A,B,tol)
% Greater-than-or-equal with tolerance.

if isempty(tol)
    expr = 0;
else
    z = grambasis(sosc,A-B);
    expr = tol*(z'*z);
end

tf = ge(sosc,A + expr, B);

end
