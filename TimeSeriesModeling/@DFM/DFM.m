% DFM  Dynamic Factor Models
%
% This section describes the `DFM` class of objects.
%
%
% Description
% ------------
%
% Dynamic factor models reduce the dynamics of a larger number of observed variables
% to a compact [VAR](VAR/index.html) estimated for a smaller number of
% common components (factors):
%
% \[ y_t = C\, f_t + \eta_t \]
% \[ f_t = \sum_{k=1}^{p} A_k\, f_{t-k} + K + B u_t \]
%
% where
%
% * \(y_t\) is an \(m\)-by-1 vector of observed variables;
% * \(f_t\) is an \(n\)-by-1 vector of factors, (\(n<m\)), following a [VAR
% specification](VAR/index.html#Description);
% * \(C\) is a factor loading matrix;
% * \(\eta_t\) is a vector of idiosyncratic errors, with
% \(\Sigma=\mathrm{E}[\eta_t \eta_t']\);
% * \(u_t\) is a vector of orthonormal VAR errors, with
% \(\Omega=\mathrm{E}[u_t u_t']\).
%
% DFM methods:
%
% Categorical List 
% -----------------
%
% __Constructor__
%
%   DFM - Create new empty DFM object
%
%
% __Properties Directly Accessible__
%
%   A - Transition matrices with higher orders concatenated horizontally
%   K - Vector of intercepts (constant terms)
%   B - Impact matrix of orthonormalized errors in factor VAR
%   C - Factor loading matrix
%   J - Impact matrix of exogenous variables
%   Mean - Mean of observed variables used to standardized their data
%   Std - Std deviations of observed variables used to standardized their data
%   Omega - Covariance matrix of reduced-form forecast errors
%   Sigma - Covariance matrix of idiosyncratic errors
%   Cross - Downscale for off-diagonal elements in idiosyncratic covariance matrix
%   
%
% __Getting Information about DFM Objects__
%
%   comment - Get or set user comments in an IRIS object
%   get - Query model object properties
%   isempty - True if VAR based object is empty
%   userdata - Get or set user data in an IRIS object
%   VAR - Return a VAR object describing the factor dynamics
%
%
% __Estimation__
%
%   estimate - Estimate DFM using static principal components
%
%
% __Filtering and Forecasting__
%
%   filter - Re-estimate factors by Kalman filtering data taking DFM coefficients as given
%   forecast - Forecast DFM factors and observables
%
%

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team
    
classdef (CaseInsensitiveProperties=true) ...
    DFM < BaseVAR

    properties
        % C  Factor loading matrix
        C = double.empty(0)

        % Mean  Mean of observed variables used to standardized their data
        Mean = double.empty(0, 1)

        % Std  Std deviations of observed variables used to standardized their data
        Std = double.empty(0, 1)

        % SingVal   Singular values of the principal components
        SingVal = [ ] 

        % B  Impact matrix of orthonormalized errors in factor VAR
        B = double.empty(0)
        
        % Sigma  Covariance matrix of idiosyncratic errors
        Sigma = double.empty(0)

        % Cross  Downscale for off-diagonal elements in idiosyncratic covariance matrix
        Cross = NaN
    end


    properties (Dependent)
        % ObservedNames  Names of observed variables in DMF object
        ObservedNames
    end
    
    
    methods
        varargout = eig(vararing)
        varargout = estimate(varargin)
        varargout = filter(varargin)
        varargout = forecast(varargin)
        varargout = get(varargin)
        varargout = mean(varargin)
        varargout = VAR(varargin)
    end
    
    
    methods (Hidden)
        varargout = stdize(varargin)
    end
    
    
    methods (Access=protected, Hidden)
        varargout = getEstimationData(varargin)
        varargout = outputFactorData(varargin)
    end
    
    
    methods (Static, Hidden)
        varargout = pc(varargin)
        varargout = estimatevar(varargin)
        varargout = cc(varargin)
        varargout = destdize(varargin)
    end
    
    
    methods
        function this = DFM(varargin)
            % DFM  Create new empty DFM object
            %
            % __Syntax__
            %
            %     F = DFM(List)
            %
            %
            % __Input Arguments__
            %
            % * `List` [ cellstr | char ] - Names of observed variables in
            % the DFM model.
            %
            %
            % __Output Arguments__
            %
            % * `F` [ DFM ] - New DFM object.
            %
            %
            % __Description__
            %
            % This function creates a new empty DFM object. It is usually followed by
            % the [estimate](DFM/estimate) function to estimate the DFM parameters
            % on data.
            %
            %
            % __Example__
            %
            % To estimate a DFM, you first need to create an empty VAR object, and
            % then run the [DFM](DFM/estimate) function on it, e.g.
            %
            %     list = {'DLCPI', 'DLGDP', 'R'};
            %     f = DFM(list);
            %     f = estimate(f, d, range);
            %
            
            % -[IrisToolbox] for Macroeconomic Modeling
            % -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team
            
            this = this@BaseVAR(varargin{:});
            if numel(varargin)==1
                if isa(varargin{1}, 'DFM')
                    this = varargin{1};
                    return
                end
            end
        end%
    end


    methods
        function list = get.ObservedNames(this)
            list = this.EndogenousNames;
        end%
    end
end
