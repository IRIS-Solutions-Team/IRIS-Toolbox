function [T,R,k,Z,H,d,U,Cov] = sspace(This,varargin)
% sspace  Quasi-triangular state-space representation of VAR.
%
% Syntax
% =======
%
%     [T,R,K,Z,H,D,Cov] = sspace(V,...)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object.
%
% Output arguments
% =================
%
% * `T` [ numeric ] - Transition matrix.
%
% * `R` [ numeric ] - Matrix of instantaneous effect of residuals (forecast
% errors).
%
% * `K` [ numeric ] - Constant vector in transition equations.
%
% * `Z` [ numeric ] - Matrix mapping transition variables to measurement
% variables.
%
% * `H` [ numeric ] - Matrix at the shock vector in measurement
% equations (all zeros in VAR objects).
%
% * `D` [ numeric ] - Constant vector in measurement equations (all zeros
% in VAR objects).
%
% * `U` [ numeric ] - Transformation matrix for predetermined variables.
%
% * `Cov` [ numeric ] - Covariance matrix of residuals (forecast errors).
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

if ~isempty(varargin) && isnumericscalar(varargin{1}) 
   Alt = varargin{1};
   varargin(1) = [ ]; %#ok<NASGU>
else
   Alt = ':';
end

%--------------------------------------------------------------------------

ny = size(This.A,1);
p = size(This.A,2) / max(ny,1);

T = This.T(:,:,Alt);
n3 = size(T,3);

U = This.U(:,:,Alt);
Z = U(1:ny,:,:);
R = permute(U(1:ny,:,:),[2,1,3]);

% Constant term.
K = This.K(:,:,Alt);
k = repmat(zeros(size(K)),p,1);
for i3 = 1 : n3
   k(:,:,i3) = transpose(U(1:ny,:,i3))*K(:,:,i3);
end

H = zeros(ny,ny,n3);
d = zeros(ny,1,n3);

% Covariance matrix of forecast errors.
Cov = This.Omega(:,:,Alt);

end