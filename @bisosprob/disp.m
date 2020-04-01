function disp(obj)
% Display information about the bilinear SOS problem.

fprintf('Bilinear sum-of-squares problem:\n');
fprintf('\n');
fprintf('\tConstraints\t\t\t%d\n', numconstraints(obj));
fprintf('\t... bilinear\t\t\t%d\n', numconstraints(obj,false));
fprintf('\n');
fprintf('\tVariables\t\t\t%d\n', numvariables(obj));
fprintf('\t... decision variables\t\t%d\n', numvariables(obj,'decvars'));
fprintf('\t...... scalars\t\t\t%d\n', numvariables(obj,'scalar'));
fprintf('\t...... initial values\t\t%d\n', numvariables(obj,'initial'));
fprintf('\t... subsidary variables\t\t%d\n', numvariables(obj,'subvars'));
fprintf('\n');

end