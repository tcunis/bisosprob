function tf = getol(sosc,A,B,tol)
% Greater-than-or-equal with tolerance.

if isempty(tol)
    tol = 0;
end

tf = ge(sosc,A + tol, B);

end
