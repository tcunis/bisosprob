function q = subs(p,symbols,assigns)
% Replace formal by actual variables.

assert(isequal(fieldnames(symbols),fieldnames(assigns)), 'Formal and actual variables must coincide.')

smb = struct2array(symbols);
asg = struct2array(assigns);

q = subs(p,smb,asg);

end
