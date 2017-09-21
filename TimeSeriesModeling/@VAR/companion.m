function [A,B,K,J] = companion(This,varargin)
% companion  Matrices of first-order companion VAR.
%
% Syntax
% =======
%
%     [A,B,K,J] = companion(V)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object for which the companion matrices will be
% returned.
%
% Output arguments
% =================
%
% * `A` [ numeric ] - First-order companion transition matrix.
%
% * `B` [ numeric ] - First-order companion coefficient matrix in front of
% reduced-form residuals.
%
% * `K` [ numeric ] - First-order compnaion constant vector.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

ny = size(This.A,1);
p = size(This.A,2) / max(ny,1);
nAlt = size(This.A,3);

if p == 0
    A = zeros(ny,ny,nAlt);
else
    A = zeros(ny*p,ny*p,nAlt);
    for i = 1 : nAlt
        A(:,:,i) = [This.A(:,:,i);eye(ny*(p-1),ny*p)];
    end
end

if nargout > 1
    B = mybmatrix(This);
    B = [B;zeros(ny*(p-1),ny,nAlt)];
end

if nargout > 2
    K = This.K;
    K(end+(1:ny*(p-1)),:,:) = 0;
end

if nargout > 3
    J = This.J;
    J(end+(1:ny*(p-1)),:,:) = 0;
end

end