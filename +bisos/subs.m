function [q,smb,asg] = subs(p,symbols,assigns,varargin)
% Replace formal by actual variables.

if nargin < 4
    assert(isequal(fieldnames(symbols),fieldnames(assigns)), 'Formal and actual variables must coincide.')
end

smb = struct2array(symbols,varargin{:});
asg = struct2array(assigns,varargin{:});

q = subs(p,smb,asg);

end
