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
            % standardized  Standardized Normal distribution
            this = distribution.Normal( );
            this.Mean = 0;
            this.Var = 1;
            populateParameters(this);
        end


        function this = fromMeanVar(varargin)
            % fromMeanVar  Normal distribution from mean and variance
            this = distribution.Normal( );
            [this.Mean, this.Var] = varargin{1:2};
            populateParameters(this);
        end


        function this = fromMeanStd(varargin)
            % fromMeanStd  Normal distribution from mean and std deviation
            this = distribution.Normal( );
            [this.Mean, this.Std] = varargin{1:2};
            populateParameters(this);
        end


        function this = fromMedianVar(varargin)
            % fromMedianVar  Normal distribution from median and variance
            this = distribution.Normal( );
            [this.Median, this.Var] = varargin{1:2};
            this.Mean = this.Median;
            populateParameters(this);
        end


        function this = fromMedianStd(varargin)
            % fromMedianStd  Normal distribution from median and std deviation
            this = distribution.Normal( );
            [this.Median, this.Std] = varargin{1:2};
            this.Mean = this.Median;
            populateParameters(this);
        end


        function this = fromModeVar(varargin)
            % fromModeVar  Normal distribution from mode and variance
            this = distribution.Normal( );
            [this.Mode, this.Var] = varargin{1:2};
            this.Mean = this.Mode;
            populateParameters(this);
        end


        function this = fromModeStd(varargin)
            % fromModeStd  Normal distribution from mode and std deviation
            this = distribution.Normal( );
            [this.Mode, this.Std] = varargin{1:2};
            this.Mean = this.Mode;
            populateParameters(this);
        end
    end
end
