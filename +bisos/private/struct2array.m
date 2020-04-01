function z = struct2array(s, fnames)
% Create array representing struct fields.

if nargin < 2
    fnames = fieldnames(s);
end

z1 = cellfun(@(fn) s.(fn)(:), fnames, 'UniformOutput', false);

z = vertcat(z1{:});