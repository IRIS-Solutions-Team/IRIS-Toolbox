% InvGamma  Inverse Gamma distribution object
%
%
% Inverse Gamma methods:
%
% __Constructors__
%
% The following are static constructors and need to be called with
% `distribution.InvGamma.` preceding their names.
%
%   fromShapeScale - Inverse Gamma distribution from shape and scale parameters
%   fromAlphaBeta - Inverse Gamma distribution from alpha and beta parameters 
%   fromMeanVar - Inverse Gamma distribution from mean and variance
%   fromMeanStd - Inverse Gamma distribution from mean and std deviation
%   fromModeVar - Inverse Gamma distribution from mode and variance
%   fromModeStd - Inverse Gamma distribution from mode and std deviation
%
%
% __Distribution Properties__
%
% These properties are directly accessible through the distribution object,
% followed by a dot and the name of a property.
%
%   Name - Name of the distribution
%   Domain - Domain of the distribution
%
%   Alpha - Alpha (scale) parameter of the distribution
%   Beta - Beta (shape) parameter of the distribution
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

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

classdef InvGamma ...
    < distribution.Distribution

    properties (SetAccess=protected)
        % Alpha  Alpha (shape) parameter of the distribution
        Alpha

        % Beta  Beta (scale) parameter of the distribution
        Beta
    end


    properties (Constant, Hidden)
        MAX_ALPHA = 1e10;
    end


    methods
        function this = InvGamma(varargin)
            this.Name = 'InvGamma';
            this.Domain = [0, Inf];
            this.Location = 0;
        end%


        function y = logPdfInDomain(this, x)
            y = -(this.Alpha + 1)*log(x) - this.Beta./x;
        end%


        function y = infoInDomain(this, x)
            x2 = x.^2;
            x3 = x.^3;
            y = -(this.Alpha + 1)./x2 + 2*this.Beta./x3;
        end%
    end


    methods (Access=protected)
        function y =  sampleIris(this, dim)
            % Create auxiliary Gamma(alpha, 1/beta)
            gamma = distribution.Gamma();
            gamma.Alpha = this.Alpha;
            gamma.Beta = 1/this.Beta;
            y = 1 ./ sampleIris(gamma, dim);
        end%


        function y =  sampleStats(this, dim)
            % Create auxiliary Gamma(alpha, 1/beta)
            gamma = distribution.Gamma();
            gamma.Alpha = this.Alpha;
            gamma.Beta = 1/this.Beta;
            y = 1 ./ sampleStats(gamma, dim);
        end%


        function populateParameters(this)
            this.Mode = this.Beta ./ (this.Alpha + 1);
            if ~isfinite(this.Mean) && this.Alpha>1
                this.Mean = this.Beta ./ (this.Alpha - 1);
            end
            if ~isfinite(this.Var) && this.Alpha>2
                this.Var = this.Mean^2 ./ (this.Alpha - 2);
            end
            if ~isfinite(this.Std)
                this.Std = sqrt(this.Var);
            end
            if ~isfinite(this.Shape)
                this.Shape = this.Alpha;
            end
            if ~isfinite(this.Scale)
                this.Scale = this.Beta;
            end
            this.LogConstant = this.Alpha*log(this.Beta) - gammaln(this.Alpha);
        end%


        function alphaBetaFromMeanVar(this)
            this.Alpha = this.Mean^2/this.Var + 2;
            this.Beta = this.Mean*(this.Alpha - 1);
        end%


        function alphaBetaFromModeVar(this)
            k = this.Var/this.Mode^2;
            obj = @(Alpha) (Alpha+1)^2 - k*(Alpha-1)^2*(Alpha-2);
            this.Alpha = fzero(obj, [2+eps(), this.MAX_ALPHA]);
            this.Beta = this.Mode * (this.Alpha + 1);
        end%
    end


    methods (Static)
        function this = fromShapeScale(varargin)
            % fromShapeScale  Inverse Gamma distribution from shape and scale parameters
            this = distribution.InvGamma( );
            [this.Shape, this.Scale] = varargin{1:2};
            this.Alpha = this.Shape;
            this.Beta = this.Scale;
            populateParameters(this);
        end%


        function this = fromAlphaBeta(varargin)
            % fromAlphaBeta  Inverse Gamma distribution from alpha and beta parameters of underlying Gamma distribution
            this = distribution.InvGamma( );
            [this.Alpha, this.Beta] = varargin{1:2};
            populateParameters(this);
        end%


        function this = fromMeanVar(varargin)
            % fromMeanVar  Inverse Gamma distribution from mean and variance
            this = distribution.InvGamma( );
            [this.Mean, this.Var] = varargin{1:2};
            alphaBetaFromMeanVar(this);
            populateParameters(this);
        end%


        function this = fromMeanStd(varargin)
            % fromMeanStd  Inverse Gamma distribution from mean and std deviation
            this = distribution.InvGamma( );
            [this.Mean, this.Std] = varargin{1:2};
            alphaBetaFromMeanVar(this);
            populateParameters(this);
        end%


        function this = fromModeVar(varargin)
            % fromModeVar  Inverse Gamma distribution from mode and variance
            this = distribution.InvGamma( );
            [this.Mode, this.Var] = varargin{1:2};
            alphaBetaFromModeVar(this);
            populateParameters(this);
        end%


        function this = fromModeStd(varargin)
            % fromModeStd  Inverse Gamma distribution from mode and std deviation
            this = distribution.InvGamma( );
            [this.Mode, this.Std] = varargin{1:2};
            alphaBetaFromModeVar(this);
            populateParameters(this);
        end%
    end
end
