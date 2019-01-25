% Gamma  Gamma distribution object
%
%
% Gamma methods:
%
% __Constructors__
%
% The following are static constructors and need to be called with
% `distribution.Gamma.` preceding their names.
%
%   fromShapeScale - Gamma distribution from shape and scale parameters
%   fromAlphaBeta - Gamma distribution from alpha and beta parameters
%   fromMeanVar - Gamma distribution from mean and variance
%   fromMeanStd - Gamma distribution from mean and std deviation
%   fromModeVar - Gamma distribution from mode and variance
%   fromModeStd - Gamma distribution from mode and std deviation
%
%
% __Distribution Properties__
%
% These properties are directly accessible through the distribution object,
% followed by a dot and the name of a property.
%
%   Alpha - Alpha (shape) parameter of Gamma distribution
%   Beta - Beta (scale) parameter of Gamma distribution
%   Lower - Lower bound of distribution domain
%   Upper - Upper bound of distribution domain
%   Mean - Mean (expected value) of distribution
%   Var - Variance of distribution
%   Std - Standard deviation of distribution
%   Mode - Mode of distribution
%   Median - Median of distribution
%   Location - Location parameter of distribution
%   Shape - Shape parameter of distribution
%   Scale - Scale parameter of distribution
%
%
% __Density Related Functions__
%
%   pdf - Probability density function
%   logPdf - Log of probability density function up to constant
%   info - Minus second derivative of log of probability density function
%   inDomain - True for data points within domain of distribution function
%
%
% __Description__
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

%--------------------------------------------------------------------------

classdef Gamma < distribution.Abstract
    properties (SetAccess=protected)
        % Alpha  Alpha (shape) parameter of Gamma distribution
        Alpha = NaN       

        % Beta  Beta (scale) parameter of Gamma distribution
        Beta = NaN        
    end


    properties (SetAccess=protected, Hidden)
        Constant = NaN    % Integration constant
        LogConstant = NaN % Log of integration constant
    end


    methods
        function this = Gamma(varargin)
            this = this@distribution.Abstract(varargin{:});
            this.Name = 'Gamma';
            this.Lower = 0;
            this.Upper = Inf;
            this.Location = 0;
        end


        function y = logPdf(this, x)
            y = zeros(size(x));
            indexInDomain = inDomain(this, x);
            x = x(indexInDomain);
            y(indexInDomain) = (this.Alpha - 1)*log(x) - x/this.Beta;
            y(~indexInDomain) = -Inf;
        end


        function y = pdf(this, x)
            y = zeros(size(x));
            indexInDomain = inDomain(this, x);
            x = x(indexInDomain);
            % y(indexInDomain) = x.^(this.Alpha-1).*exp(-x/this.Beta) * this.Constant;
            y(indexInDomain) = exp( logPdf(this, x) + this.LogConstant );
        end


        function y = info(this, x)
            y = nan(size(x));
            indexInDomain = inDomain(this, x);
            x = x(indexInDomain);
            y(indexInDomain) = (this.Alpha - 1) / x.^2;
        end
    end


    methods (Access=protected)
        function populateParameters(this)
            if ~isfinite(this.Mean)
                this.Mean = this.Alpha*this.Beta;
            end
            if ~isfinite(this.Mode)
                this.Mode = max(0, (this.Alpha-1)*this.Beta);
            end
            if ~isfinite(this.Var)
                this.Var = this.Alpha * this.Beta.^2;
            end
            if ~isfinite(this.Std)
                this.Std = sqrt(this.Var);
            end
            this.Shape = this.Alpha;
            this.Scale = this.Beta;
            this.LogConstant = -(this.Alpha*log(this.Beta) + gammaln(this.Alpha));
            this.Constant = 1./(this.Beta^this.Alpha * gamma(this.Alpha));
        end


        function alphaBetaFromMeanVar(this)
            this.Beta = this.Var / this.Mean;
            this.Alpha = this.Mean / this.Beta;
        end


        function alphaBetaFromModeVar(this)
            k = this.Mode^2/this.Var + 2;
            this.Alpha = fzero(@(x) x+1/x - k, [1+1e-10, 1e10]);
            this.Beta = this.Mode/(this.Alpha - 1);
        end
    end


    methods (Static)
        function this = fromShapeScale(varargin)
            % fromShapeScale  Gamma distribution from shape and scale parameters
            this = distribution.Gamma.fromAlphaBeta(varargin{:});
        end


        function this = fromAlphaBeta(varargin)
            % fromAlphaBeta  Gamma distribution from alpha and beta parameters
            this = distribution.Gamma( );
            [this.Alpha, this.Beta] = varargin{1:2};
            populateParameters(this);
        end


        function this = fromMeanVar(varargin)
            % fromMeanVar  Gamma distribution from mean and variance
            this = distribution.Gamma( );
            [this.Mean, this.Var] = varargin{1:2};
            alphaBetaFromMeanVar(this);
            populateParameters(this);
        end


        function this = fromMeanStd(varargin)
            % fromMeanStd  Gamma distribution from mean and std deviation
            this = distribution.Gamma( );
            [this.Mean, this.Std] = varargin{1:2};
            this.Var = this.Std.^2;
            alphaBetaFromMeanVar(this);
            populateParameters(this);
        end


        function this = fromModeVar(varargin)
            % fromModeStd  Gamma distribution from mode and variance
            this = distribution.Gamma( );
            [this.Mode, this.Var] = varargin{1:2};
            alphaBetaFromModeVar(this);
            populateParameters(this);
        end


        function this = fromModeStd(varargin)
            % fromModeStd  Gamma distribution from mode and std deviation
            this = distribution.Gamma( );
            [this.Mode, this.Std] = varargin{1:2};
            this.Var = this.Std^2;
            alphaBetaFromModeVar(this);
            populateParameters(this);
        end
    end
end
