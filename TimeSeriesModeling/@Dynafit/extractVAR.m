function V = VAR(this)
% VAR  Return VAR object for factor dynamics
%
% Syntax
% =======
%
%     v = VAR(a)
%
% Input arguments
% ================
%
% `a` [ DFM ] - DFM object.
%
% Output arguments
% =================
%
% `v` [ VAR ] - VAR object describing the dynamic system of the DFM
% factors.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

% TODO: Use parent VAR objects.

nx = size(this.A, 1);
p = size(this.A, 2) / nx;
nv = countVariants(this);

% Create and populate a struct.
V = struct( );
V.A = this.A; % Untransformed transition matrices.
V.K = zeros([nx, nv]); % Constant vector.
V.B = this.B;
V.Std = 1;
V.Omega = this.Omega; % Cov of reduced-form residuals.
% if q<nx
   % for ialt = 1 : nv
      % V.Omega(:, :, ialt) = this.B(:, :, ialt)*this.B(:, :, ialt)';
   % end
   % V.B = [V.B, zeros(nx, nx-q, nv)];
% end
V.Sigma = [ ]; % Cov of parameters.
V.T = this.T; % Shur decomposition of transition matrix.
V.U = this.U; % Schur transformation of variables.
V.Range = this.Range; % User range.
V.IxFitted = this.IxFitted; % Effective estimation sample.
V.Rr = [ ]; % Parameter restrictions.
V.NHyper = nx*p; % Number of estimated hyperparameters.
V.EigVal = this.EigVal; % Vector of eigenvalues.
V.ResidualNames = this.FactorResidualNames; % Names of residuals.
% w.Aic, w.Sbc to be populated within VAR( ).

% Convert the struct to a VAR object
V = VAR(this.FactorNames);
V.Order = p;
V.A = this.A;
V.K = zeros([nx, nv]);
V.Omega = this.Omega;
V.Sigma = [];
V.T = this.T;
V.U = this.U;
V.Range = this.Range;
V.IxFitted = this.IxFitted;
V.Rr = [];
V.NHyper = nx*p;
V.EigVal = this.EigVal;
V.ResidualNames = this.FactorResidualNames;

end%

