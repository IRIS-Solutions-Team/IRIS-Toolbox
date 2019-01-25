% Uniform  Uniform distribution object
%
%
% Uniform methods:
%
% __Constructors__
%
% The following are static constructors and need to be called with
% `distribution.Uniform.` preceding their names.
%
%   fromLowerUpper - Uniform distribution from lower and upper bounds
%   fromMeanVar - Uniform distribution from mean and variance
%   fromMeanStd - Uniform distribution from mean and std deviation
%   fromMedianVar - Uniform distribution from median and variance
%   fromMedianStd - Uniform distribution from median and std deviation
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
%   Median - Median of distribution
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

classdef Uniform < distribution.Abstract
    properties (SetAccess=protected, Hidden)
        Pdf = NaN
    end


    methods
        function this = Uniform(varargin)
            this = this@distribution.Abstract(varargin{:});
            this.Name = 'Uniform';
        end


        function y = logPdf(this, x)
            indexInDomain = inDomain(this, x);
            y = zeros(size(x));
            y(indexInDomain) = 0;
            y(~indexInDomain) = -Inf;
        end


        function y = pdf(this, x)
            indexInDomain = inDomain(this, x);
            y = zeros(size(x));
            y(indexInDomain) = this.Pdf;
        end


        function y = info(this, x)
            y = zeros(size(x));
        end
    end


    methods (Access=protected)
        function populateParameters(this)
            if ~isfinite(this.Mean)
                this.Mean = (this.Lower + this.Upper)/2;
            end
            if ~isfinite(this.Median)
                this.Median = (this.Lower + this.Upper)/2;
            end
            if ~isfinite(this.Var)
                this.Var = (this.Upper - this.Lower)^2/12;
            end
            if ~isfinite(this.Std)
                this.Std = sqrt(this.Var);
            end
            if ~isfinite(this.Location)
                this.Location = this.Lower;
            end
            if ~isfinite(this.Scale)
                this.Scale = this.Upper - this.Lower;
            end
            this.Pdf = 1./this.Scale;
        end
    end


    methods (Static)
        function this = fromLowerUpper(varargin)
            % fromLowerUpper  Uniform distribution from lower and upper bounds
            this = distribution.Uniform( );
            [this.Lower, this.Upper] = varargin{:};
            populateParameters(this);
        end


        function this = fromMeanVar(varargin)
            % fromMeanVar  Uniform distribution from mean and variance
            this = distribution.Uniform( );
            this = distribution.Uniform( );
            [this.Mean, this.Var] = varargin{1:2};
            this.Std = sqrt(this.Var);
            this.fromMeanStd(this);
        end


        function this = fromMeanStd(varargin)
            % fromMeanVar  Uniform distribution from mean and std deviation
            if nargin==1
                this = varargin{1};
            else
                this = distribution.Uniform( );
                [this.Mean, this.Std] = varargin{1:2};
            end
            this.Upper = sqrt(12)*this.Std/2 + this.Mean;
            this.Lower = 2*this.Mean - this.Upper;
            populateParameters(this);
        end


        function fromMedianVar(varargin)
            % fromMeanVar  Uniform distribution from median and variance
            this = distribution.Uniform( );
            [this.Median, this.Var] = varargin{1:2};
            this.Mean = this.Median;
            this.Std = sqrt(this.Var);
            fromMeanStd(this);
        end


        function fromMedianStd(varargin)
            % fromMeanVar  Uniform distribution from median and std deviation
            this = distribution.Uniform( );
            [this.Median, this.Std] = varargin{1:2};
            this.Mean = this.Median;
            fromMeanStd(this);
        end
    end
end
