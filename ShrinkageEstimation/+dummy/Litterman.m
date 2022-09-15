% litterman  Litterman's prior dummy observations for BVARs
%{
% ## Syntax ##
%
%
%     [b, y0, K, y1, G] = BVAR.litterman(rho, mu, lambda)
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
% case each variable evals different weight); if you use the option
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


classdef Litterman < dummy.Base
    properties
        Rho = 0 % [0, 1]
        Mu = 0 % [0, Inf)
        Lambda (1, 1) double {mustBeNonnegative} = 0
    end


    methods
        function this = Litterman(rho, mu, lambda)
            if nargin==0
                return
            end
            this.Rho = rho;
            this.Mu = mu;
            if nargin>=3
                this.Lambda = lambda;
            end
        end%


        function y0 = evalY(this, var)
            [numY, numK, ~, order] = dummy.Base.getDimensions(var);
            numColumns = numY * order;
            y0 = this.Mu .* this.Rho;
            if isscalar(y0) && numY>1
                y0 = repmat(y0, numY, 1);
            end
            y0 = [diag(y0), zeros(numY, numColumns-numY)];
        end%


        function k = evalK(this, var)
            [numY, numK, ~, order] = dummy.Base.getDimensions(var);
            numColumns = numY * order;
            k = zeros(numK, numColumns);
        end%


        function y1 = evalZ(this, var)
            [numY, numK, ~, order] = dummy.Base.getDimensions(var);
            sgm = this.Mu * 1;
            if isscalar(sgm) && numY>1
                sgm = repmat(sgm, numY, 1);
            end
            sgm = repmat(sgm, 1, order);
            if this.Lambda>0
                lags = (1 : order) .^ this.Lambda;
                lags = repmat(lags, numY, 1);
                sgm = sgm .* lags;
            end
            y1 = diag(sgm(:));
        end%


        function x = evalX(this, var)
            [numY, numK, numX, order] = dummy.Base.getDimensions(var);
            numColumns = numY * order;
            x = zeros(numX, numColumns);
        end%
    end
end

