% Normal  Normal distribution object
%
%
% Normal methods:
%
% __Constructors__
%
%   distribution.Normal.standardized - Standarized Normal distribution
%   distribution.Normal.fromMeanVar - Normal distribution from mean and variance
%   distribution.Normal.fromMeanStd - Normal distribution from mean and std deviation
%   distribution.Normal.fromMedianVar - Normal distribution from median and variance
%   distribution.Normal.fromMedianStd - Normal distribution from median and std deviation
%   distribution.Normal.fromModeVar - Normal distribution from mode and variance
%   distribution.Normal.fromModeStd - Normal distribution from mode and std deviation
%
%
% __Distribution Properties__
%
% These properties are directly accessible through the distribution object,
% followed by a dot and the name of a property.
%
%   Lower - Lower bound of distribution domain
%   Upper - Upper bound of distribution domain
%   Mean - Mean (expected value) of distribution
%   Var - Variance of distribution
%   Std - Standard deviation of distribution
%   Mode - Mode of distribution
%   Median - Median of distribution
%   Location - Location parameter of distribution
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
% -Copyright (c) 2007-2018 IRIS Solutions Team.

%--------------------------------------------------------------------------

classdef Normal < distribution.Abstract
    properties 
        Constant = NaN
    end


    methods
        function this = Normal(varargin)
            this = this@distribution.Abstract(varargin{:});
            this.Name = 'Normal';
            this.Lower = -Inf;
            this.Upper = Inf;
        end


        function y = logPdf(this, x)
            y = -0.5*( (x - this.Mean).^2 ./ this.Var );
        end


        function y = pdf(this, x)
            y = logPdf(this, x);
            y = this.Constant * exp(y);
        end


        function y = info(this, x)
            y = 1/this.Var;
            y = y(ones(size(x)));
        end
    end


    methods (Access=protected)
        function populateParameters(this)
            if ~isfinite(this.Std)
                this.Std = sqrt(this.Var);
            end
            if ~isfinite(this.Var)
                this.Var = this.Std^2;
            end
            this.Location = this.Mean;
            this.Scale = this.Std;
            this.Mode = this.Mean;
            this.Median = this.Mean;
            this.Constant = 1/(sqrt(2*pi)*this.Std);
        end
    end


    methods (Static)
        function this = standardized( )
            % distribution.Normal.standardized  Standardized Normal distribution
            this = distribution.Normal( );
            this.Mean = 0;
            this.Var = 1;
            populateParameters(this);
        end


        function this = fromMeanVar(varargin)
            % distribution.Normal.fromMeanVar  Normal distribution from mean and variance
            this = distribution.Normal( );
            [this.Mean, this.Var] = varargin{1:2};
            populateParameters(this);
        end


        function this = fromMeanStd(varargin)
            % distribution.Normal.fromMeanStd  Normal distribution from mean and std deviation
            this = distribution.Normal( );
            [this.Mean, this.Std] = varargin{1:2};
            populateParameters(this);
        end


        function this = fromMedianVar(varargin)
            % distribution.Normal.fromMedianVar  Normal distribution from median and variance
            this = distribution.Normal( );
            [this.Median, this.Var] = varargin{1:2};
            this.Mean = this.Median;
            populateParameters(this);
        end


        function this = fromMedianStd(varargin)
            % distribution.Normal.fromMedianStd  Normal distribution from median and std deviation
            this = distribution.Normal( );
            [this.Median, this.Std] = varargin{1:2};
            this.Mean = this.Median;
            populateParameters(this);
        end


        function this = fromModeVar(varargin)
            % distribution.Normal.fromModeVar  Normal distribution from mode and variance
            this = distribution.Normal( );
            [this.Mode, this.Var] = varargin{1:2};
            this.Mean = this.Mode;
            populateParameters(this);
        end


        function this = fromModeStd(varargin)
            % distribution.Normal.fromModeStd  Normal distribution from mode and std deviation
            this = distribution.Normal( );
            [this.Mode, this.Std] = varargin{1:2};
            this.Mean = this.Mode;
            populateParameters(this);
        end
    end
end
