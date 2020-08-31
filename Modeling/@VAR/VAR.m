% VAR  Vector Autoregressions
%
% This section describes the `VAR` class of objects
%
% Description
% ------------
%
% VAR objects can be constructed as plain VARs or simple panel VARs (with
% fixed effect), and estimated without or with prior dummy observations
% (quasi-bayesian VARs). VAR objects are reduced-form models but they are also
% the point of departure for identifying structural VARs
% ([`SVAR`](SVAR/index.html) objects).
%
% VAR models in IRIS have the following form:
%
% \[
% y_t = \sum_{k=1}^{p} A_k\, y_{t-k} + K + J g_t + \epsilon_t
% \]
%
% where
%
% * \(y_t\) is an \(n\)-by-1 vector of endogenous variables;
% * \(A_k\) are transition matrices at lags 1, ..., k;
% * \(K\) is a vector of intercepts;
% * \(g_t\) is a vector of exogenous variables;
% * \(J\) is the impact matrix of exogenous variables;
% * \(\epsilon_t\) is a vector of forecast (reduced-form) errors, with
% \(\Omega=\mathrm{E}[\epsilon_t \epsilon_t']\).
%
%
% VAR methods:
%
%
% Categorical List 
% -----------------
%
% __Constructor__
%
%   VAR - Create new empty reduced-form VAR object
%
%
% __Properties Directly Accessible__
%
%   A - Transition matrices with higher orders concatenated horizontally
%   K - Vector of intercepts (constant terms)
%   J - Impact matrix of exogenous variables
%   Omega - Covariance matrix of reduced-form forecast errors
%   Sigma - Covariance matrix of parameter estimates
%   AIC - Akaike information criterion
%   AICc - Akaike information criterion corrected for small sample
%   SBC - Schwarz bayesian criterion
%   EigenValues - Eigenvalues of VAR transition matrix
%   EigenStability - Stability indicator for each eigenvalue
%   Range - Estimation range entered by user
%   InxFitted - Logical index of dates in estimation range acutally fitted
%   EndogenousNames - Names of endogenous variables
%   ResidualNames - Names of errors
%   ExogenousNames - Names of exogenous variables
%   GroupNames - Names of groups in panel VARs
%   ConditioningNames - Names of conditioning instruments
%   NumEndogenous - Number of endogenous variables
%   NumResiduals - Number of errors
%   NumExogenous - Number of exogenous variables
%   NumGroups - Number of groups in panel VARs
%   NumConditioning - Number of conditioning instruments
%
%
% __Getting Information about VAR Objects__
% >
%
%   addToDatabank - Add VAR parameters to databank or create new databank
%   comment - Get or set user comments in an IRIS object
%   companion - Matrices of first-order companion VAR
%   eig - Eigenvalues of a VAR process
%   fprintf - Write VAR model as formatted model code to text file
%   get - Query VAR object properties
%   testCompatible - True if two VAR objects can occur together on the LHS and RHS in an assignment
%   isexplosive - True if any eigenvalue is outside unit circle
%   isstationary - True if all eigenvalues are within unit circle
%   length - Number of parameter variants in VAR object
%   mean - Asymptotic mean of VAR process
%   nfitted - Number of data points fitted in VAR estimation
%   rngcmp - True if two VAR objects have been estimated using the same dates
%   sprintf - Print VAR model as formatted model code
%   sspace - Quasi-triangular state-space representation of VAR
%   userdata - Get or set user data in an IRIS object
%
%
% __Referencing VAR Objects__
% >
%
%   group - Retrieve VAR object from panel VAR for specified group of data
%   subsasgn - Subscripted assignment for VAR objects
%   subsref - Subscripted reference for VAR objects
%
%
% __Simulation, Forecasting and Filtering__
% >
%
%   ferf - Forecast error response function
%   filter - Filter data using a VAR model
%   forecast - Unconditional or conditional VAR forecasts
%   instrument - Define forecast conditioning instruments in VAR models
%   resample - Resample from a VAR object
%   simulate - Simulate VAR model
%
%
% __Manipulating VARs__
%
%   assign - Manually assign system matrices to VAR object
%   alter - Expand or reduce the number of alternative parameterisations within a VAR object
%   backward - Backward VAR process
%   demean - Remove constant and the effect of exogenous inputs from VAR object
%   horzcat - Combine two compatible VAR objects in one object with multiple parameterisations integrate - Integrate VAR process and data associated with it
%   xasymptote - Set or get asymptotic assumptions for exogenous inputs
%
%
% __Stochastic Properties__
%
%   acf - Autocovariance and autocorrelation functions for VAR variables
%   fmse - Forecast mean square error matrices
%   vma - Matrices describing the VMA representation of a VAR process
%   xsf - Power spectrum and spectral density functions for VAR variables
%
%
% __Estimation, Identification, and Statistical Tests__
%
%   estimate - Estimate a reduced-form VAR or BVAR
%   infocrit - Populate information criteria for a parameterised VAR
%   lrtest - Likelihood ratio test for VAR models
%   portest - Portmanteau test for autocorrelation in VAR residuals
%   schur - Compute and store triangular representation of VAR
%

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team
    
classdef (CaseInsensitiveProperties=true) VAR ...
    < BaseVAR ...
    & matlab.mixin.CustomDisplay ...
    & shared.DatabankPipe

    properties
        G = [ ] % Coefficients at cointegrating vector in VEC form.

        % Sigma  Covariance matrix of parameter estimates
        Sigma = double.empty(0, 0, 0)

        % AIC  Akaike information criterion
        AIC = double.empty(1, 0)

        % AICc  Akaike information criterion corrected for small sample
        AICc = double.empty(1, 0)

        % SBC  Schwarz bayesian criterion
        SBC = double.empty(1, 0)

        Rr = [ ] % Parameter restrictions.
        NHyper = NaN % Number of estimated hyperparameters.
    end




    properties (Dependent)
        CovParameters
    end




    methods
        varargout = addToDatabank(varargin)
        varargout = assign(varargin)
        varargout = acf(varargin)
        varargout = backward(varargin)
        varargout = companion(varargin)
        varargout = datarequest(varargin)
        varargout = demean(varargin)
        varargout = eig(varargin)
        varargout = estimate(varargin)
        varargout = ferf(varargin)
        varargout = filter(varargin)
        varargout = fmse(varargin)
        varargout = forecast(varargin)
        varargout = forecast2(varargin)
        varargout = fprintf(varargin)
        varargout = get(varargin)
        varargout = group(varargin)
        varargout = infocrit(varargin)
        varargout = instrument(varargin)
        varargout = integrate(varargin)
        varargout = testCompatible(varargin)
        varargout = isexplosive(varargin)
        varargout = isstationary(varargin)
        varargout = lrtest(varargin)
        varargout = mean(varargin)
        varargout = portest(varargin)
        varargout = resample(varargin)
        varargout = simulate(varargin)
        varargout = sprintf(varargin)
        varargout = sspace(varargin)
        varargout = vma(varargin)
        varargout = xasymptote(varargin)
        varargout = xsf(varargin)
        varargout = subsref(varargin)
        varargout = subsasgn(varargin)


        function [minSh, maxSh] = getActualMinMaxShifts(this)
            minSh = -this.Order;
            maxSh = 0;
        end%
    end
    
    
    methods (Hidden)
        varargout = hdatainit(varargin)
        varargout = end(varargin)
        varargout = saveobj(varargin)
        varargout = implementGet(varargin)
        varargout = SVAR(varargin)
        varargout = myresponse(varargin)
        varargout = mysystem(varargin)
    end
    
    
    methods (Access=protected, Hidden)
        varargout = assignEst(varargin)
        varargout = getEstimationData(varargin)
        varargout = prepareLsqWeights(varargin)
        varargout = myisvalidinpdata(varargin)
        varargout = preallocate(varargin)
        varargout = myrngcmp(varargin);
        varargout = subsalt(varargin)
        varargout = size(varargin)
        varargout = specdisp(varargin)
        varargout = stackData(varargin)
    end
    
    
    methods (Static, Hidden)
        varargout = generalizedLsq(varargin)
        varargout = restrict(varargin)
        varargout = smoother(varargin)
    end
    
    
    methods (Access=protected, Hidden)
        % Methods sealed in extension classes svarobj.
        varargout = mybmatrix(varargin)
        varargout = mycovmatrix(varargin)
    end

    
    methods
        function this = VAR(varargin)
% VAR  Create new empty reduced-form VAR object.
%{
% Syntax for Plain VAR and VAR with Exogenous Variables
%--------------------------------------------------------------------------
%
%     V = VAR(EndogenousNames)
%     V = VAR(EndogenousNames, "Exogenous", ExogenousNames)
%
%
% Syntax for Panel VAR and Panel VAR with Exogenous Variables
%--------------------------------------------------------------------------
%
%     V = VAR(EndogenousNames, "Groups", GroupNames)
%     V = VAR(EndogenousNames, "Exogenous", ExogenousNames, "Groups", GroupNames)
%
%
% Output Arguments
%--------------------------------------------------------------------------
%
% __`V`__ [ VAR ] –
%
%>    New empty VAR model object.
%
%
% __`EndogenousNames`__ [ string ]
% 
%>    Names of endogenous variables.
%
%
% __`ExogenousNames`__ [ string ]
%
%>    Names of exogenous inputs.
%
%
% __`GroupNames`__ [ string ] 
% 
%>    Names of groups for panel VAR estimation.
%
%
% Options
%--------------------------------------------------------------------------
%
% __`Exogenous=[ ]` [ string ] 
% 
%>    Names of exogenous regressors; one of the names can be `!ttrend`, a
%>    linear time trend, which will be created automatically each time
%>    input data are required, and then included in the output database
%>    under the name `ttrend`.
%
%
% __`Groups=[ ]`__ [ string ] 
%
%>    Names of groups for panel VAR estimation.
%
%
% __`Intercept=true`___ [ `true` | `false` ] 
% 
%>    Include the intercept in the VAR model.
%
%
% __`Order=1`__ [ numeric ] 
% 
%>    Order of the VAR model, i.e. the number of lags of endogenous
%>    variables included in estimation.
%
%
% Description
%-------------------------------------------------------------------------- 
%
% Create a new empty VAR object. The VAR constructor is usually
% followed by an [`estimate`](VAR/estimate) command to estimate
% the coefficient matrices in the VAR object using some data.
%
%
% Example
%--------------------------------------------------------------------------
%
% To estimate a VAR, first create an empty VAR object specifying the
% variable names, and then run the [VAR/estimate](VAR/estimate) function on
% it, e.g.
%
%     v = VAR(["x", "y", "z"]);
%     [v, d] = estimate(v, d, range);
%
% where the input database `d` is expected to include at least the time
% series `d.x`, `d.y`, `d.z`.
%
%}

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------
            
            this = this@BaseVAR(varargin{:});
            
            if nargin==0
                return
            elseif nargin==1 && isa(varargin{1}, 'VAR')
                this = varargin{1};
                return
            elseif nargin==1 && isstruct(varargin{1})
                this = struct2obj(this, varargin{1});
                return
            end
        end%
    end


    methods
        function value = get.CovParameters(this)
            value = this.Sigma;
        end%
    end
end

