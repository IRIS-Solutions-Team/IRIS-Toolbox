function [answ, flag] = implementGet(this, query, varargin)
% implementGet  Implement get method for VAR objects
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

%--------------------------------------------------------------------------

[answ, flag] = implementGet@BaseVAR(this, query, varargin{:});
if flag
    return
end

answ = [ ];
flag = true;

ny = size(this.A, 1);
p = size(this.A, 2) / max(ny, 1);
nAlt = size(this.A, 3);

switch query
    case 'a#'
    % Transition matrix.
        if ~all(size(this.A)==0)
            answ = polyn.var2polyn(this.A);
        else
            answ = zeros(ny, ny, p, nAlt);
        end
        
        
    case 'a*'
        if ~all(size(this.A)==0)
            answ = polyn.var2polyn(this.A);
            answ = -answ(:, :, 2:end, :);
        else
            answ = zeros(ny, ny, max(0, p-1), nAlt);
        end
        
        
    case 'a$'
        answ = this.A;
        
        
    case {'const', 'c', 'k'}
        % Constant vector or matrix (for panel VARs).
        answ = this.K;
        
        
    case 'j'
        % Coefficient matrix in front exogenous inputs.
        answ = this.J;
        
        
    case 'g'
        % Estimated coefficients on user-specified cointegration terms.
        
    case 't'
        % Schur decomposition.
        answ = this.T;
        
        
    case 'u'
        answ = this.U;
        
        
    case {'omega', 'omg'}
        % Cov matrix of forecast errors (reduced form residuals); remains the
        % same in SVAR objects.
        answ = this.Omega;
        
        
    case {'cov'}
        % Cov matrix of reduced form residuals in VARs or structural shocks in
        % SVARs.
        answ = this.Omega;
        
        
    case {'sgm', 'sigma', 'covp', 'covparameters'}
        % Cov matrix of parameter estimates.
        answ = this.Sigma;
        
        
    case {'xasymptote', 'x0'}
        answ = this.X0;
        
        
    case 'aic'
        % Akaike info criterion.
        answ = this.AIC;
        
        
    case 'aicc'
        % Akaike info criterion corrected for small sample
        answ = this.AICc;
        
        
    case 'sbc'
        % Schwarz bayesian criterion.
        answ = this.SBC;
        
        
    case {'nfree', 'nhyper'}
        % Number of freely estimated (hyper-) parameters.
        answ = this.NHyper;
        
        
    case {'order', 'p'}
        % Order of VAR.
        answ = p;
        
        
    case {'cumlong', 'cumlongrun'}
        % Matrix of long-run cumulative responses.
        C = sum(polyn.var2polyn(this.A), 3);
        answ = nan(ny, ny, nAlt);
        for iAlt = 1 : nAlt
            if rank(C(:, :, 1, iAlt))==ny
                answ(:, :, iAlt) = inv(C(:, :, 1, iAlt));
            else
                answ(:, :, iAlt) = pinv(C(:, :, 1, iAlt));
            end
        end
        
        
    case {'constraints', 'restrictions', 'constraint', 'restrict'}
        % Parameter constraints imposed in estimation.
        answ = this.Rr;
        
        
    case 'ny'
        answ = size(this.A, 1);
        
        
    case 'ne'
        answ = size(this.Omega, 2);
        
        
    case 'ni'
        answ = size(this.Zi, 1);
        
        
    otherwise
        flag = false;   
end

end
