function [this, y0, k, y1, g] = litterman(rho, mu, lambda, varargin)
% litterman  Litterman's prior dummy observations for BVARs
%{
% ## Syntax ##
%
%
%     [b, Y0, K, Y1, G] = BVAR.litterman(rho, mu, lambda)
%
%
% ## Input Arguments ##
%
%
% __`rho`__ [ numeric ]
% >
% White-noise priors (`rho = 0`) or random-walk
% priors (`rho = 1`), or something in between.
%
%
% __`mu`__ [ numeric ]
% >
% Weight on dummy observations.
%
%
% __`lambda`__ [ numeric ]
% >
% Exponential increase in weight depending on the
% lag; `lambda = 0` means all lags are weighted equally.
%
%
% ## Output Arguments ##
%
%
% __`b`__ [ DummyWrapper ]
% >
% BVAR object that can be passed into the
% [`VAR/estimate`](VAR/estimate) function.
%
%
% __`y0`__ [ numeric ]
% >
% Matrix of dummy observations that will be added to the matrix of LHS
% observations of the endogenous variables.
%
%
% __`k`__ [ numeric ]
% >
% Matrix of dummy observations that will be added to the RHS intercept
% vector.
%
%
% __`y1`__ [ numeric ]
% >
% Matrix of dummy observations that will be added to the RHS matrix of 
% observations of the lags of the endogenous variables.
%
%
% __`g`__ [ numeric ]
% >
% Matrix of dummy observations that will be added to the RHS matrix of
% observations of exogenous variables (if present).
%
%
% ## Description ##
%
%
% Create Litterman-style dummy prior observations for estimating a VAR
% model. 
%
% * `rho=0` is a white-noise prior, `rho=1` is a random-walk prior; a value
% inbetween is a general autoregressive prior;
%
% * `mu` is the weight on the prior (can be a vector of numbers in which
% case each variable gets different weight); if you use the option
% `Standardize=` when estimating the VAR, `mu` can be loosely interpreted
% as the number of fictitious observations that will pull the estimates
% towards the priors;
%
% * `lambda` between 0 and Inf: priors on the `k`-th lag coefficients get
% `k^lambda` times bigger weights. If `lambda=0`, all lags are treated
% equally. Higher lambdas mean that the coefficients at higher lags are
% more heavily shrunk towards their prior value of zero.
%
% The dummy observations are arranged in up to four matrices: $$ y^0 $$ is
% added to the LHS observations, $$ k $$ is added to the intercept vector
% (if the intercept is included in the VAR), $$ y^1 $$ is added to the RHS
% observations of lagged endogenous variables, and $$ g $$ is added to the
% RHS observations of exogenous variables (if any exogenous variables are
% present in the VAR).
%
% * $$y^0_{i,j} = \mu \rho$$ for $$i=j$$
%
% * $$y^0_{i,j} = 0$$ otherwise
%
% ## Example ##
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 IRIS Solutions Team

persistent pp
if isempty(pp)
    pp = extend.InputParser('BVAR.litterman');
    addRequired(pp, 'rho', @(x) isnumeric(x) && all(x>=0 & x<=1));
    addRequired(pp, 'mu', @(x) isnumeric(x) && all(x>=0));
    addRequired(pp, 'lambda', @(x) validate.numericScalar(x, 0, Inf));
end
parse(pp, rho, mu, lambda);

%--------------------------------------------------------------------------

rho = reshape(rho, [], 1);
mu = reshape(mu, [], 1);

this = BVAR.DummyWrapper( );
this.name = 'litterman';
this.y0 = @getY0;
this.k0 = @getK0;
this.y1 = @getY1;
this.g1 = @getG1;

if ~isempty(varargin) && nargout>1
    [y0, k, y1, g] = BVAR.mydummymat(this, varargin{:});
end

return
    
    function Y0 = getY0(numY, order, ~, ~)
        nd = numY*order;
        muRho = mu .* rho;
        if length(muRho)==1 && numY>1
            muRho = muRho(ones(1, numY), 1);
        end
        Y0 = [diag(muRho), zeros(numY, nd-numY)];
    end%


    function K0 = getK0(numY, order, ~, numK)
        nd = numY*order;
        K0 = zeros(numK, nd);
    end%


    function Y1 = getY1(numY, order, ~, ~)
        sgm = mu;
        if length(sgm)==1 && numY>1
            sgm = sgm(ones(1, numY), 1);
        end
        sgm = sgm(:, ones(1, order));
        if lambda>0
            lags = (1 : order).^lambda;
            lags = lags(ones(1, numY), :);
            sgm = sgm .* lags;
        end
        Y1 = diag(sgm(:));
    end%


    function G1 = getG1(numY, order, numG, ~)
        nd = numY*order;
        G1 = zeros(numG, nd);
    end% 
end%

