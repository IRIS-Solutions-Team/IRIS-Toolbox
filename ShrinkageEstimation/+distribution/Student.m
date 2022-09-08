% Student  Student distribution object
%
%
% Student methods:
%
% __Constructors__
%
% The following are static constructors and need to be called with
% `distribution.Student.` preceding their names.
%
%   standardized - Standardized Student distribution
%   fromLocationScale - 
%   fromMeanVar - Student distribution from mean and variance
%   fromMeanStd - Student distribution from mean and std deviation
%   fromMedianVar - Student distribution from median and variance
%   fromMedianStd - Student distribution from median and std deviation
%   fromModeVar - Student distribution from mode and variance
%   fromModeStd - Student distribution from mode and std deviation
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
%   Mean - Mean (expected value) of distribution
%   Var - Variance of distribution
%   Std - Standard deviation of distribution
%   Mode - Mode of distribution
%   Median - Median of distribution
%   Location - Location parameter of distribution
%   Scale - Scale parameter of distribution
%   DegreesFreedom - Number of the degrees of freedom
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

classdef Student < distribution.Distribution
    properties 
        % DegreesFreedom  Number of the degrees of freedom
        DegreesFreedom = NaN
        
        % Mu  Location parameter of the distribution
        Mu = 0

        % Sigma  Scale parameter of the distribution
        Sigma = 1
    end


    methods
        function this = Student(varargin)
            this = this@distribution.Distribution(varargin{:});
            this.Name = 'Student';
            this.Domain = [-Inf, Inf];
        end%


        function y = logPdfInDomain(this, x)
            nu = this.DegreesFreedom;
            mu = this.Mu;
            sigma = this.Sigma;
            w = (nu + 1)/2;
            y = -w*log(1 + (1/nu)*((x - mu)/sigma).^2);
        end%


        function y = infoInDomain(this, x)
            nu = this.DegreesFreedom;
            mu = this.Mu;
            sigma = this.Sigma;
            sigma2 = sigma^2;
            w = (nu + 1)/2;
            if mu==0
                xmu2 = x.^2;
            else
                xmu2 = (x - mu).^2;
            end
            if sigma==1
                nusigma2 = nu;
            else
                nusigma2 = nu*sigma2;
            end
            y = 2*w*(nusigma2 - xmu2)./(nusigma2 + xmu2).^2;
        end%
    end


    methods (Access=protected)
        function y = sampleIris(this, dim)
            % Auxiliary ChiSquare distribution
            chi2 = distribution.ChiSquare.fromDegreesFreedom(this.DegreesFreedom);
            y = randn(dim) .* sqrt(this.DegreesFreedom ./ sampleIris(chi2, dim));
            if this.Sigma~=1
                y = this.Sigma*y;
            end
            if this.Mu~=0
                y = this.Mu + y;
            end
        end%


        function y = sampleStats(this, dim)
            y = trnd(this.DegreesFreedom, dim);
            if this.Sigma~=1
                y = this.Sigma*y;
            end
            if this.Mu~=0
                y = this.Mu + y;
            end
        end%


        function populateParameters(this)
            nu = this.DegreesFreedom;
            mu = this.Mu;
            if this.Sigma==1
                sigma = 1;
                sigma2 = 1;
            else
                sigma = this.Sigma;
                sigma2 = sigma^2;
            end
            if ~isfinite(this.Mean)
                if nu>1
                    this.Mean = mu;
                else
                    this.Mean = NaN;
                end
            end
            if ~isfinite(this.Var)
                if nu>2
                    this.Var = sigma2*nu/(nu - 2);
                elseif nu>1
                    this.Var = Inf;
                else
                    this.Var = NaN;
                end
            end
            this.Mode = this.Mean;
            this.Median = this.Mean;
            this.Location = this.Mu;
            this.Scale = this.Sigma;
            % Constant = gamma(w)/(gamma(nu/2)*sqrt(pi*nu)*sigma)
            w = (nu + 1)/2;
            this.LogConstant = gammaln(w) - gammaln(nu/2) - log(sqrt(pi*nu)*sigma);
        end%


        function muSigmaFromMeanVar(this)
            nu = this.DegreesFreedom;
            if nu>1
                this.Mu = this.Mean;
            else
                this.Mu = NaN;
                this.Mean = NaN;
            end
            if nu>2
                this.Sigma = sqrt(this.Var*(nu-2)/nu);
            else
                this.Var = NaN;
                this.Sigma = NaN;
            end
        end%
    end


    methods (Static)
        function this = standardized(varargin)
            % standardized  Standardized Student distribution
            this = distribution.Student( );
            this.DegreesFreedom = varargin{1};
            this.Mu = 0;
            this.Sigma = 1;
            populateParameters(this);
        end%


        function this = fromLocationScale(varargin)
            % fromLocationScale  Student distribution from location and scale parameters
            this = distribution.Student( );
            this.DegreesFreedom = varargin{1};
            [this.Mu, this.Sigma] = varargin{2:3};
            populateParameters(this);
        end%


        function this = fromMeanVar(varargin)
            % fromMeanVar  Student distribution from mean and variance
            this = distribution.Student( );
            this.DegreesFreedom = varargin{1};
            [this.Mean, this.Var] = varargin{2:3};
            muSigmaFromMeanVar(this);
            populateParameters(this);
        end%


        function this = fromMeanStd(varargin)
            % fromMeanStd  Student distribution from mean and std deviation
            this = distribution.Student( );
            this.DegreesFreedom = varargin{1};
            [this.Mean, this.Std] = varargin{2:3};
            muSigmaFromMeanVar(this);
            populateParameters(this);
        end%


        function this = fromMedianVar(varargin)
            % fromMedianVar  Student distribution from median and variance
            this = distribution.Student( );
            this.DegreesFreedom = varargin{1};
            [this.Median, this.Var] = varargin{2:3};
            this.Mean = this.Median;
            muSigmaFromMeanVar(this);
            populateParameters(this);
        end%


        function this = fromMedianStd(varargin)
            % fromMedianStd  Student distribution from median and std deviation
            this.DegreesFreedom = varargin{1};
            [this.Median, this.Std] = varargin{2:3};
            this.Mean = this.Median;
            muSigmaFromMeanVar(this);
            populateParameters(this);
        end%


        function this = fromModeVar(varargin)
            % fromModeVar  Student distribution from mode and variance
            this = distribution.Student( );
            this.DegreesFreedom = varargin{1};
            [this.Mode, this.Var] = varargin{2:3};
            this.Mean = this.Mode;
            muSigmaFromMeanVar(this);
            populateParameters(this);
        end%


        function this = fromModeStd(varargin)
            % fromModeStd  Student distribution from mode and std deviation
            this.DegreesFreedom = varargin{1};
            [this.Mode, this.Std] = varargin{2:3};
            this.Mean = this.Mode;
            muSigmaFromMeanVar(this);
            populateParameters(this);
        end%
    end
end
