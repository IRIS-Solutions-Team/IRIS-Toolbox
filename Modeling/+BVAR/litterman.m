function [this, Y0, K0, Y1, G1] = litterman(rho, mu, lambda, varargin)
% litterman  Litterman's prior dummy observations for BVARs
%
% Syntax
% =======
%
%     O = BVAR.litterman(rho, mu, lambda)
%
% Input arguments
% ================
%
% * `rho` [ numeric ] - White-noise priors (`rho = 0`) or random-walk
% priors (`rho = 1`), or something in between.
%
% * `mu` [ numeric ] - Weight on dummy observations.
%
% * `lambda` [ numeric ] - Exponential increase in weight depending on the
% lag; `lambda = 0` means all lags are weighted equally.
%
% Output arguments
% =================
%
% * `O` [ bvarobj ] - BVAR object that can be passed into the
% [`VAR/estimate`](VAR/estimate) function.
%
% Description
% ============
%
% Create Litterman-style dummy prior observations for estimating a VAR
% model. 
%
% * `rho` = 0 is a white-noise prior, `rho` = 1 is a random-walk prior;
%
% * `mu` is the weight on the prior (can be a vector of numbers in which
% case each variable gets different weight); if you use the option
% `'stdize'` when estimating the BVAR, `mu` can be loosely interpreted as
% the number of fictitious observations that will pull the estimates
% towards the priors;
%
% * `lambda` between 0 and Inf: priors on the `k`-th lag coefficients get
% `k^lambda` times bigger weights. If `lambda` = 0, all lags are treated
% equally. The higher the lambda, the more the coefficients are pulled
% towards the priors (zero in this case);
%
%
% Example
% ========
%

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2019 IRIS Solutions Team

persistent pp
if isempty(pp)
    pp = extend.InputParser('BVAR.litterman');
    addRequired(pp, 'rho', @(x) isnumeric(x) && all(x>=0 & x<=1));
    addRequired(pp, 'mu', @(x) isnumeric(x) && all(x>=0));
    addRequired(pp, 'lambda', @(x) validate.numericScalar(x, 0, Inf));
end
parse(pp, rho, mu, lambda);

%--------------------------------------------------------------------------

rho = rho(:);
mu = mu(:);

this = BVAR.bvarobj( );
this.name = 'litterman';
this.y0 = @y0;
this.k0 = @k0;
this.y1 = @y1;
this.g1 = @g1;

if ~isempty(varargin) && nargout>1
    [Y0, K0, Y1, G1] = BVAR.mydummymat(this, varargin{:});
end

return
    
    function Y0 = y0(numY, order, ~, ~)
        nd = numY*order;
        muRho = mu .* rho;
        if length(muRho) == 1 && numY > 1
            muRho = muRho(ones(1, numY), 1);
        end
        Y0 = [diag(muRho), zeros(numY, nd-numY)];
    end%


    function K0 = k0(numY, order, ~, numK)
        nd = numY*order;
        K0 = zeros(numK, nd);
    end%


    function Y1 = y1(numY, order, ~, ~)
        sgm = mu;
        if length(sgm) == 1 && numY > 1
            sgm = sgm(ones(1, numY), 1);
        end
        sgm = sgm(:, ones(1, order));
        if lambda > 0
            lags = (1 : order).^lambda;
            lags = lags(ones(1, numY), :);
            sgm = sgm .* lags;
        end
        Y1 = diag(sgm(:));
    end%


    function G1 = g1(numY, order, numG, ~)
        nd = numY*order;
        G1 = zeros(numG, nd);
    end% 
end%

