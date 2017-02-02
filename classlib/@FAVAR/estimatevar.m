function [A,B,Omg,T,U,u,Fitted] = estimatevar(X,P,Q)
% estimatevar  [Not a public function] Estimate VAR(p,q) on factors.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

nx = size(X,1);
nPer = size(X,2);

% Stack vectors of x(t), x(t-1), etc.
t = P+1 : nPer;
presample = nan(nx,P);
x0 = [presample,X(:,t)];
x1 = [ ];
for i = 1 : P
   x1 = [x1;presample,X(:,t-i)]; %#ok<AGROW>
end

% Determine dates with no missing observations.
Fitted = all(~isnan([x0;x1]));
nObs = sum(Fitted);

% Estimate VAR and reduced-form residuals.
A = x0(:,Fitted)/x1(:,Fitted);
e = x0 - A*x1;
Omg = e(:,Fitted)*e(:,Fitted)'/nObs;

% Number of orthonormalised shocks driving the factor VAR.
if Q > nx
   Q = nx;
end

% Compute principal components of reduced-form residuals, back out
% orthonormalised residuals.
% e = B u,
% Euu' = I.
[B,u] = covfun.orthonorm(Omg,Q,1,e);
B = B(:,1:Q,:);
u = u(1:Q,:,:);

% Tringularise FAVAR system.
%     x = A [x(-1);...;x(-p)] + [B;0] u
%     a = T a(-1) + U(1:nx,:)' B u.
% where x = U a.
AA = [A;eye(nx*(P-1),nx*P)];
[U,T] = schur(AA);

end
