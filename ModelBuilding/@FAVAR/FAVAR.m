% FAVAR  Factor-Augmented Vector Autoregressions (FAVAR Objects).
%
% FAVAR methods:
%
% Constructor
% ============
%
% * [`FAVAR`](FAVAR/FAVAR) - Create new empty FAVAR object.
%
%
% Getting information about FAVAR objects
% ========================================
%
% * [`comment`](FAVAR/comment) - Get or set user comments in an IRIS object.
% * [`get`](FAVAR/get) - Query model object properties.
% * [`isempty`](FAVAR/isempty) - True if VAR based object is empty.
% * [`userdata`](FAVAR/userdata) - Get or set user data in an IRIS object.
% * [`VAR`](FAVAR/VAR) - Return a VAR object describing the factor dynamics.
%
%
% Estimation
% ===========
%
% * [`estimate`](FAVAR/estimate) - Estimate FAVAR using static principal components.
%
%
% Filtering and forecasting
% ==========================
%
% * [`filter`](FAVAR/filter) - Re-estimate the factors by Kalman filtering the data taking FAVAR coefficients as given.
% * [`forecast`](FAVAR/forecast) - Forecast FAVAR factors and observables.
%
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.
    
classdef FAVAR < varobj
    properties
        Mean = [ ] % Vector of estimated means used to standardise the input data.
        Std = [ ] % Vector of estimated stdevs used to standardise the input data.
        SingVal = [ ] % Singular values of the principal components.
        B = [ ] % Coefficient matrix at orthonormalised shocks in factor VAR.
        C = [ ] % Measurement matrix.
        
        Sigma = [ ] % Cov of idiosyncratic residuals.
        Cross = NaN;
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
        varargout = standardise(varargin)
    end
    
    
    methods (Access=protected, Hidden)
        varargout = myny(varargin)
        varargout = getEstimationData(varargin)
        varargout = outputFactorData(varargin)
    end
    
    
    methods (Static, Hidden)
        varargout = pc(varargin)
        varargout = estimatevar(varargin)
        varargout = cc(varargin)
        varargout = destandardise(varargin)
    end
    
    
    methods
        function this = FAVAR(varargin)
            % FAVAR  Create new empty FAVAR object.
            %
            % Syntax
            % =======
            %
            %     f = FAVAR(list)
            %
            %
            % Input arguments
            % ================
            %
            % * `list` [ cellstr | char ] - Names of observed variables in the FAVAR model.
            %
            %
            % Output arguments
            % =================
            %
            % * `f` [ FAVAR ] - New FAVAR object.
            %
            %
            % Description
            % ============
            %
            % This function creates a new empty FAVAR object. It is usually followed by
            % the [estimate](FAVAR/estimate) function to estimate the FAVAR parameters
            % on data.
            %
            %
            % Example
            % ========
            %
            % To estimate a FAVAR, you first need to create an empty VAR object, and
            % then run the [FAVAR](FAVAR/estimate) function on it, e.g.
            %
            %     list = {'DLCPI', 'DLGDP', 'R'};
            %     f = FAVAR(list);
            %     f = estimate(f, d, range);
            %
            
            % -IRIS Macroeconomic Modeling Toolbox.
            % -Copyright (c) 2007-2018 IRIS Solutions Team.
            
            this = this@varobj(varargin{:});
            if length(varargin)==1
                if isa(varargin{1}, 'FAVAR')
                    this = varargin{1};
                    return
                end
            end
        end
    end
end
