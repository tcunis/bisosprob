function tf = eqtol(sosc,A,B,tol)
% Equals with tolerance.

if ~isempty(tol)
    error('Equals with tolerance not supported.')
end

% else:
tf = eq(sosc, A, B);

end
