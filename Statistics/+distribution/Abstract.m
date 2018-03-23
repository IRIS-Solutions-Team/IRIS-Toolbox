% distribution.Abstract

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

classdef (Abstract) Abstract < handle
    properties (SetAccess=protected)
        % Name  Name of distribution
        Name = ''

        % Lower  Lower bound of distribution domain
        Lower = NaN

        % Upper  Upper bound of distribution domain
        Upper = NaN

        % Location  Location parameter of distribution
        Location = NaN

        % Scale  Scale parameter of distribution
        Scale = NaN

        % Shape  Shape parameter of distribution
        Shape = NaN
        
        % Mean  Mean (expected value) of distribution
        Mean = NaN

        % Var  Variance of distribution
        Var = NaN

        % Std  Standard deviation of distribution
        Std = NaN

        % Mode  Mode of distribution
        Mode = NaN 

        % Median  Median of distribution
        Median = NaN
    end


    methods
        function this = Abstract( )
        end
    end


    methods (Abstract)
        % logPdf  Log of probability density function up to constant
        varargout = logPdf(varargin)

        % pdf  Probability density function
        varargout = pdf(varargin)

        % info  Minus second derivative of log of probability density function
        varargout = info(varargin)
    end


    methods
        function indexInDomain = inDomain(this, x)
            % inDomain  True for data points within domain of distribution function
            indexInDomain = x>=this.Lower & x<=this.Upper;
        end


        function this = set.Lower(this, lower)
            assert( ...
                isnan(this.Upper) || lower<this.Upper, ...
                exception.Base('Distribution:Abstract:LowerUpperBounds', 'error') ...
            );
            this.Lower = lower;
        end


        function this = set.Upper(this, upper)
            assert( ...
                isnan(this.Lower) || upper>this.Lower, ...
                exception.Base('Distribution:Abstract:UpperLowerBounds', 'error') ...
            );
            this.Upper = upper;
        end
    end


    methods (Abstract, Access=protected)
        varargout = populateParameters(varargin)
    end
end
