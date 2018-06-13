function [T,R,k,Z,H,d,U,Cov] = sspace(This,varargin)
% sspace  Quasi-triangular state-space representation of SVAR.
%
% Syntax
% =======
%
%     [T,R,K,Z,H,D,Cov] = sspace(V,...)
%
% Input arguments
% ================
%
% * `V` [ SVAR ] - SVAR object.
%
% Output arguments
% =================
%
% * `T` [ numeric ] - Transition matrix.
%
% * `R` [ numeric ] - Matrix of instantaneous effect of structural shocks.
%
% * `K` [ numeric ] - Constant vector in transition equations.
%
% * `Z` [ numeric ] - Matrix mapping transition variables to measurement
% variables.
%
% * `H` [ numeric ] - Matrix at the shock vector in measurement
% equations (all zeros in SVAR objects).
%
% * `D` [ numeric ] - Constant vector in measurement equations (all zeros
% in SVAR objects).
%
% * `U` [ numeric ] - Transformation matrix for predetermined variables.
%
% * `Cov` [ numeric ] - Covariance matrix of structural shocks.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

if ~isempty(varargin) && isnumericscalar(varargin{1}) 
   Alt = varargin{1};
   varargin(1) = [ ]; %#ok<NASGU>
else
   Alt = ':';
end

%--------------------------------------------------------------------------

[T,R,k,Z,H,d,U,~] = sspace@VAR(This,Alt);
n3 = size(T,3);

% Matrix of instantaneous effect of structural shocks.
B = This.B(:,:,Alt);
for i3 = 1 : n3
    R(:,:,i3) = R(:,:,i3)*B(:,:,i3);
end

% Covariance matrix of structural shocks.
Cov = mycovmatrix(This,Alt);

end