function [A,R] = ginverse(A)
% ginverse  [Not a public function] Generalised inverse of square matrix.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

% `A` must be square matrix (no check performed)

if isempty(A)
    A = zeros(size(A),class(A));
    return
end

% Determine the rank of `A`.
m = size(A,1);
s = svd(A);
tol = m * eps(max(s));
R = sum(s > tol);

% Calculate inverse or pseudo-inverse depending on the rank.
if (R == m)
    A = inv(A);
elseif (R == 0)
    A = zeros(size(A),class(A));
else
    [u,~,v] = svd(A,0);
    s = diag(1./s(1:R));
    A = v(:,1:R)*s*transpose(u(:,1:R));
end

end
