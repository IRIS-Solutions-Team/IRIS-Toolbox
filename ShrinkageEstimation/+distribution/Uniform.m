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
%   Name - Name of the distribution
%   Domain - Domain of the distribution
%
%   Lower - Lower bound of the uniform interval
%   Upper - Upper bound of the uniform interval
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


% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

classdef Uniform ...
    < distribution.Distribution

    properties (SetAccess=protected, Hidden)
        % Lower  Lower bound of the uniform interval
        Lower = 0
        
        % Upper  Upper bound of the uniform interval
        Upper = 1
    end


    methods
        function this = Uniform(varargin)
            this = this@distribution.Distribution(varargin{:});
            this.Name = 'Uniform';
            this.Domain = [NaN, NaN];
        end%


        function y = logPdfInDomain(this, x)
            y = zeros(size(x));
        end%


        function y = infoInDomain(~, x)
            y = zeros(size(x));
        end%
    end
        
        
    methods (Access=protected)
        function y = sampleIris(this, dim)
            y = this.Lower + (this.Upper-this.Lower)*rand(dim);
        end%
        
        
        function y = sampleStats(this, dim)
            y = unifrnd(this.Lower, this.Upper, dim);
        end%


        function populateParameters(this)
            this.Domain = [this.Lower, this.Upper];
            if ~isfinite(this.Mean)
                this.Mean = (this.Lower + this.Upper)/2;
            end
            if ~isfinite(this.Median)
                this.Median = (this.Lower + this.Upper)/2;
            end
            if ~isfinite(this.Var)
                this.Var = (this.Upper - this.Lower)^2/12;
            end
            if ~isfinite(this.Location)
                this.Location = this.Lower;
            end
            if ~isfinite(this.Scale)
                this.Scale = this.Upper - this.Lower;
            end
            this.LogConstant = -log(this.Scale);
        end%
    end




    methods (Static)
        function this = fromLowerUpper(varargin)
            % fromLowerUpper  Uniform distribution from lower and upper bounds
            this = distribution.Uniform( );
            [this.Lower, this.Upper] = varargin{:};
            populateParameters(this);
        end%


        function this = fromMeanVar(varargin)
            % fromMeanVar  Uniform distribution from mean and variance
            this = distribution.Uniform( );
            [this.Mean, this.Var] = varargin{1:2};
            this.fromMeanStd(this);
        end%


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
        end%


        function fromMedianVar(varargin)
            % fromMeanVar  Uniform distribution from median and variance
            this = distribution.Uniform( );
            [this.Median, this.Var] = varargin{1:2};
            this.Mean = this.Median;
            fromMeanStd(this);
        end%


        function fromMedianStd(varargin)
            % fromMeanVar  Uniform distribution from median and std deviation
            this = distribution.Uniform( );
            [this.Median, this.Std] = varargin{1:2};
            this.Mean = this.Median;
            fromMeanStd(this);
        end%
    end
end
