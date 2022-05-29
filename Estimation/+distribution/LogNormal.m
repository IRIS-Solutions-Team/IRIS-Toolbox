% LogNormal  LogNormal distribution object
%
%
% LogNormal methods:
%
% __Constructors__
%
% The following are static constructors and need to be called with
% `distribution.LogNormal.` preceding their names.
%
%   standardized - Standardized LogNormal distribution
%   fromMeanVar - LogNormal distribution from mean and variance
%   fromMeanStd - LogNormal distribution from mean and std deviation
%   fromMedianVar - LogNormal distribution from median and variance
%   fromMedianStd - LogNormal distribution from median and std deviation
%   fromModeVar - LogNormal distribution from mode and variance
%   fromModeStd - LogNormal distribution from mode and std deviation
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
%   Mean - Mean (expected value) of the distribution
%   Var - Variance of the distribution
%   Std - Standard deviation of the distribution
%   Mode - Mode of the distribution
%   Median - Median of the distribution
%   Location - Location parameter of the distribution
%   Scale - Scale parameter of the distribution
%
%
% __Density Related Functions__
%
%   pdf - Probability density function
%   logPdf - Log of probability density function up to a constant
%   info - Minus second derivative of log of probability density function
%   inDomain - True for data points within domain of the distribution function
%   draw - 
%
%
% __Description__
%

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

classdef LogNormal ...
    < distribution.Distribution

    properties
        % Mu  Mean of the underlying Normal distribution
        Mu

        % Sigma  Standard deviation of the underlying Normal distribution
        Sigma
    end


    methods
        function this = LogNormal(varargin)
            this = this@distribution.Distribution(varargin{:});
            this.Name = 'LogNormal';
            this.Domain = [0, Inf];
            this.Location = 0;
        end%


        function y = logPdfInDomain(this, x)
            logX = log(x);
            y = -0.5*( (logX - this.Mu).^2 ./ this.Sigma.^2 ) - logX;
        end%


        function y = infoInDomain(this, x)
            x2 = s.^2;
            sigma2 = this.Sigma.^2;
            y = (1 - sigma2 + this.Mu - log(x)) ./ (sigma2 .* x2);
        end%
    end


    methods (Access=protected)
        function y = sampleIris(this, dim)
            y = exp(this.Mu + this.Sigma*randn(dim));
        end%
        
        
        function y = sampleStats(this, dim)
            y = lognrnd(this.Mu, this.Sigma, dim);
        end%


        function populateParameters(this)
            sigma2 = this.Sigma.^2;
            if ~isfinite(this.Mean) || isempty(this.Mean)
                this.Mean = exp(this.Mu + sigma2/2);
            end
            if ~isfinite(this.Mode) || isempty(this.Mode)
                this.Mode = exp(this.Mu - sigma2);
            end
            if ~isfinite(this.Median) || isempty(this.Median)
                this.Median = exp(this.Mu);
            end
            if ~isfinite(this.Var) || isempty(this.Var)
                this.Var = (exp(sigma2)-1).*this.Mean.^2;
            end
            if ~isfinite(this.Scale) || isempty(this.Scale)
                this.Scale = exp(this.Mu);
            end
            if ~isfinite(this.Shape) || isempty(this.Shape)
                this.Shape = this.Sigma;
            end
            this.LogConstant = -log(this.Sigma) - 0.5*log(2*pi); 
        end%


        function muSigmaFromMeanVar(this)
            sigma2 = log(1 + this.Var/this.Mean.^2);
            this.Sigma = sqrt(sigma2);
            this.Mu = log(this.Mean) - sigma2/2;
        end%


        function muSigmaFromMedianVar(this)
            this.Mu = log(this.Median);
            twoMu = 2*this.Mu;
            var__ = this.Var;
            sigma2 = fzero(@(sigma2) -var__ + (exp(sigma2)-1).*exp(twoMu+sigma2), 1);
            this.Sigma = sqrt(sigma2);
        end%


        function muSigmaFromModeVar(this)
            logMode = log(this.Mode);
            logVar = log(this.Var);
            logVarFunc = @(expSigma2) -logVar + reallog(expSigma2-1) + 2*(logMode + 1.5*log(expSigma2));
            expSigma2 = fzero(logVarFunc, [1+1e-10, 1e10]);
            sigma2 = log(expSigma2);
            this.Sigma = sqrt(sigma2);
            this.Mu = logMode + sigma2;
        end%
    end


    methods (Static)
        function this = standardized( )
            % standardized  Standardized LogNormal distribution
            this = distribution.LogNormal( );
            this.Mu = 0;
            this.Sigma = 1;
            populateParameters(this);
        end%


        function this = fromShapeScale(varargin)
            this = distribution.LogNormal( );
            [this.Shape, this.Scale] = varargin{:};
            this.Sigma = this.Shape;
            this.Mu = log(this.Scale);
            populateParameters(this);
        end%


        function this = fromMuSigma(varargin)
            this = distribution.LogNormal( );
            [this.Mu, this.Sigma] = varargin{:};
            populateParameters(this);
        end%


        function this = fromMeanVar(varargin)
            % fromMeanVar  LogNormal distribution from mean and variance
            this = distribution.LogNormal( );
            [this.Mean, this.Var] = varargin{1:2};
            muSigmaFromMeanVar(this);
            populateParameters(this);
        end%


        function this = fromMeanStd(varargin)
            % fromMeanStd  LogNormal distribution from mean and std deviation
            this = distribution.LogNormal( );
            [this.Mean, this.Std] = varargin{1:2};
            muSigmaFromMeanVar(this);
            populateParameters(this);
        end%


        function this = fromMedianVar(varargin)
            % fromMedianVar  LogNormal distribution from median and variance
            this = distribution.LogNormal( );
            [this.Median, this.Var] = varargin{1:2};
            muSigmaFromMedianVar(this);
            populateParameters(this);
        end%


        function this = fromMedianStd(varargin)
            % fromMedianStd  LogNormal distribution from median and std deviation
            this = distribution.LogNormal( );
            [this.Median, this.Std] = varargin{1:2};
            muSigmaFromMedianVar(this);
            populateParameters(this);
        end%


        function this = fromModeVar(varargin)
            % fromModeVar  LogNormal distribution from mode and variance
            this = distribution.LogNormal( );
            [this.Mode, this.Var] = varargin{1:2};
            muSigmaFromModeVar(this);
            populateParameters(this);
        end%


        function this = fromModeStd(varargin)
            % fromModeStd  LogNormal distribution from mode and std deviation
            this = distribution.LogNormal( );
            [this.Mode, this.Std] = varargin{1:2};
            muSigmaFromModeVar(this);
            populateParameters(this);
        end%
    end
end
