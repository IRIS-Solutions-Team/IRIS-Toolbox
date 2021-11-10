% Dynamo  Dynamic Factor Models
%
% This section describes the `Dynamo` class of objects.
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
% Dynamo methods:
%
% Categorical List
% -----------------
%
% __Constructor__
%
%   Dynamo - Create new empty Dynamo object
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
% __Getting Information about Dynamo Objects__
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
%   estimate - Estimate Dynamo using static principal components
%
%
% __Filtering and Forecasting__
%
%   filter - Re-estimate factors by Kalman filtering data taking Dynamo coefficients as given
%
%

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

classdef (CaseInsensitiveProperties=true) ...
    Dynamo < BaseVAR

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

        ResidualNamePattern (1, 2) string = ["res_", ""]

        FactorNamePattern (1, 2) string = ["factor", ""]

        CommonNamePattern (1, 2) string = ["cc_", ""]

        ContributionNamePattern (1, 2) string = ["contrib_", ""]
    end


    properties (Dependent)
        % ObservedNames  Names of observed variables in DMF object
        ObservedNames

        FactorNames

        FactorResidualNames

        IdiosyncraticResidualNames

        CommonNames

        ContributionNames

        NumFactors
    end


    methods
        varargout = access(varargin)
        varargout = eig(vararing)
        varargout = estimate(varargin)
        varargout = kalmanFilter(varargin)
        varargout = get(varargin)
        varargout = extractVAR(varargin)
        varargout = solutionMatrices(varargin)
        varargout = simulate(varargin)
    end


    methods (Hidden)
        varargout = stdize(varargin)
    end


    methods (Access=protected, Hidden)
        varargout = getEstimationData(varargin)
        varargout = outputFactorData(varargin)

        function groups = getPropertyGroups(this)
            x = struct( );
            x.ObservedNames = this.ObservedNames;
            x.FactorNames = this.FactorNames;
            x.NumObserved = numel(this.ObservedNames);
            x.NumFactors = numel(this.FactorNames);
            x.Order = this.Order;
            x.NumVariants = countVariants(this);
            x.Comment = string(this.Comment);
            x.UserData = this.UserData;
            groups = matlab.mixin.util.PropertyGroup(x);
        end% 
    end


    methods (Static, Hidden)
        varargout = pc(varargin)
        varargout = cc(varargin)
        varargout = destdize(varargin)
    end


    methods
        function this = Dynamo(list, options)
            % Dynamo  Create new empty Dynamo object
            %
            % __Syntax__
            %
            %     F = Dynamo(List)
            %
            %
            % __Input Arguments__
            %
            % * `List` [ cellstr | char ] - Names of observed variables in
            % the Dynamo model.
            %
            %
            % __Output Arguments__
            %
            % * `F` [ Dynamo ] - New Dynamo object.
            %
            %
            % __Description__
            %
            % This function creates a new empty Dynamo object. It is usually followed by
            % the [estimate](Dynamo/estimate) function to estimate the Dynamo parameters
            % on data.
            %
            %
            % __Example__
            %
            % To estimate a Dynamo, you first need to create an empty VAR object, and
            % then run the [Dynamo](Dynamo/estimate) function on it, e.g.
            %
            %     list = {'DLCPI', 'DLGDP', 'R'};
            %     f = Dynamo(list);
            %     f = estimate(f, d, range);
            %

            % -[IrisToolbox] for Macroeconomic Modeling
            % -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

            arguments
                list (1, :) string
                options.Mean (:, 1) double = double.empty(0, 1)
                options.Std (:, 1) double = double.empty(0, 1)
                options.Order (1, 1) double = 1
            end

            this = this@BaseVAR();
            this.EndogenousNames = list;

            if isscalar(options.Mean)
                options.Mean = repmat(options.Mean, numel(list), 1);
            end
            this.Mean = options.Mean;

            if isscalar(options.Std)
                options.Std = repmat(options.Std, numel(list), 1);
            end
            this.Std = options.Std;

            this.Order = options.Order;
        end%
    end


    methods
        function x = get.ObservedNames(this)
            x = this.EndogenousNames;
        end%


        function x = get.FactorNames(this)
            x = textual.fromPattern(string(1:this.NumFactors), this.FactorNamePattern);
        end%


        function x = get.FactorResidualNames(this)
            x = textual.fromPattern(this.FactorNames, this.ResidualNamePattern);
        end%


        function x = get.IdiosyncraticResidualNames(this)
            x = textual.fromPattern(this.EndogenousNames, this.ResidualNamePattern);
        end%


        function x = get.CommonNames(this)
            x = textual.fromPattern(this.EndogenousNames, this.CommonNamePattern);
        end%


        function x = get.ContributionNames(this)
            x = textual.fromPattern(this.EndogenousNames, this.ContributionNamePattern);
        end%


        function x = get.NumFactors(this)
            x = size(this.A, 1);
        end%
    end
end
