% Normal  Normal distribution object
%
%
% Normal methods:
%
% __Constructors__
%
% The following are static constructors and need to be called with
% `distribution.Normal.` preceding their names.
%
%   standardized - Standardized Normal distribution
%   fromMeanVar - Normal distribution from mean and variance
%   fromMeanStd - Normal distribution from mean and std deviation
%   fromMedianVar - Normal distribution from median and variance
%   fromMedianStd - Normal distribution from median and std deviation
%   fromModeVar - Normal distribution from mode and variance
%   fromModeStd - Normal distribution from mode and std deviation
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

classdef Normal ...
    < distribution.Distribution

    methods
        function this = Normal(varargin)
            this = this@distribution.Distribution(varargin{:});
            this.Name = 'Normal';
            this.Domain = [-Inf, Inf];
        end%


        function y = logPdfInDomain(this, x)
            y = -0.5*( (x - this.Mean).^2 ./ this.Var );
        end%


        function y = infoInDomain(this, x)
            y = 1/this.Var;
            y = y(ones(size(x)));
        end%
    end


    methods (Access=protected)
        function y = sampleIris(this, dim)
            y = this.Mean + this.Std*randn(dim);
        end%
        
        
        function y = sampleStats(this, dim)
            y = normrnd(this.Mean, this.Std, dim);
        end%


        function populateParameters(this)
            this.Location = this.Mean;
            this.Scale = this.Std;
            this.Mode = this.Mean;
            this.Median = this.Mean;
            this.LogConstant = -log(this.Std) - 0.5*log(2*pi); 
        end%
    end


    methods (Static)
        function this = standardized( )
            % standardized  Standardized Normal distribution
            this = distribution.Normal( );
            this.Mean = 0;
            this.Var = 1;
            populateParameters(this);
        end%


        function this = fromMeanVar(varargin)
            % fromMeanVar  Normal distribution from mean and variance
            this = distribution.Normal( );
            [this.Mean, this.Var] = varargin{1:2};
            populateParameters(this);
        end%


        function this = fromMeanStd(varargin)
            % fromMeanStd  Normal distribution from mean and std deviation
            this = distribution.Normal( );
            [this.Mean, this.Std] = varargin{1:2};
            populateParameters(this);
        end%


        function this = fromMedianVar(varargin)
            % fromMedianVar  Normal distribution from median and variance
            this = distribution.Normal( );
            [this.Median, this.Var] = varargin{1:2};
            this.Mean = this.Median;
            populateParameters(this);
        end%


        function this = fromMedianStd(varargin)
            % fromMedianStd  Normal distribution from median and std deviation
            this = distribution.Normal( );
            [this.Median, this.Std] = varargin{1:2};
            this.Mean = this.Median;
            populateParameters(this);
        end%


        function this = fromModeVar(varargin)
            % fromModeVar  Normal distribution from mode and variance
            this = distribution.Normal( );
            [this.Mode, this.Var] = varargin{1:2};
            this.Mean = this.Mode;
            populateParameters(this);
        end%


        function this = fromModeStd(varargin)
            % fromModeStd  Normal distribution from mode and std deviation
            this = distribution.Normal( );
            [this.Mode, this.Std] = varargin{1:2};
            this.Mean = this.Mode;
            populateParameters(this);
        end%
    end
end
