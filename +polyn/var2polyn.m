function A = var2polyn(A)
% var2polyn  Convert VAR style matrix to 3D polynomial.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isa(A, 'VAR')
   A = get(A, 'A');
end

[ny, p, nv] = size(A);
p = p/ny;
x = eye(ny);
x = x(:, :, 1, ones(1, nv));
A = cat(3, x, reshape(-A, [ny, ny, p, nv]));

end
