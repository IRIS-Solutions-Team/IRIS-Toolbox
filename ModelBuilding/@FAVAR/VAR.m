function V = VAR(A)
% VAR  Return a VAR object describing the factor dynamics.
%
% Syntax
% =======
%
%     v = VAR(a)
%
% Input arguments
% ================
%
% `a` [ FAVAR ] - FAVAR object.
%
% Output arguments
% =================
%
% `v` [ VAR ] - VAR object describing the dynamic system of the FAVAR
% factors.
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

% TODO: Use parent VAR objects.

[~,nx,p,q,nalt] = size(A);

% Create and populate a struct.
V = struct( );
V.A = A.A; % Untransformed transition matrices.
V.K = zeros([nx,nalt]); % Constant vector.
V.B = A.B;
V.Std = 1;
V.Omega = A.Omega; % Cov of reduced-form residuals.
if q < nx
   for ialt = 1 : nalt
      V.Omega(:,:,ialt) = A.B(:,:,ialt)*A.B(:,:,ialt)';
   end
   V.B = [V.B,zeros([nx,nx-q,nalt])];
end
V.Sigma = [ ]; % Cov of parameters.
V.T = A.T; % Shur decomposition of transition matrix.
V.U = A.U; % Schur transformation of variables.
V.Range = A.Range; % User range.
V.IxFitted = A.IxFitted; % Effective estimation sample.
V.Rr = [ ]; % Parameter restrictions.
V.NHyper = nx*p; % Number of estimated hyperparameters.
V.EigVal = A.EigVal; % Vector of eigenvalues.
V.YNames = @(n) sprintf('factor%g',n); % Names of endogenous variables.
V.ENames = @(yname,n) ['res_',yname]; % Names of residuals.
% w.Aic, w.Sbc to be populated within VAR( ).

% Convert the struct to a VAR object.
V = VAR(V);

end
