% distribution.Abstract

% -[IrisToolbox] Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

classdef (Abstract) Abstract < matlab.mixin.Copyable
    properties
        % Name  Name of the distribution
        Name
        
        % Doain  Domain of the distribution
        Domain

        % Location  Location parameter of the distribution
        Location = NaN

        % Scale  Scale parameter of the distribution
        Scale = NaN

        % Shape  Shape parameter of the distribution
        Shape = NaN
        
        % Mean  Mean (expected value) of the distribution
        Mean = NaN

        % Var  Variance of the distribution
        Var = NaN

        % Mode  Mode of the distribution
        Mode = NaN 

        % Median  Median of the distribution
        Median = NaN

        % LogConstant  Log of integration constant
        LogConstant = 0
    end


    properties (SetAccess=protected, Dependent)
        % Std  Std deviation of the distribution
        Std
    end


    methods (Abstract)
        % logPdfInDomain  Log of probability density function up to a constant within domain
        varargout = logPdfInDomain(varargin)

        % infoInDomain  Minus second derivative of the log of probability density function within domain
        varargout = infoInDomain(varargin)
        
        % sample  Sample randomly from the distribution
        varargout = sample(varargin)
    end


    methods
        function inxInDomain = inDomain(this, x)
            inxInDomain = x>=this.Domain(1) & x<=this.Domain(2);
        end%
    end


    methods (Abstract, Access=protected)
        varargout = populateParameters(varargin)
    end


    methods
        function y = logPdf(this, x)
            y = zeros(size(x));
            inxInDomain = inDomain(this, x);
            if any(inxInDomain)
                x = x(inxInDomain);
                y(inxInDomain) = logPdfInDomain(this, x);
            end
            y(~inxInDomain) = -Inf;
        end%


        function y = info(x)
            y = zeros(size(x));
            inxInDomain = inDomain(this, x);
            if any(inxInDomain)
                x = x(inxInDomain);
                y(inxInDomain) = infoInDomain(this, x);
            end
        end%


        function y = pdf(this, x)
            y = exp( logPdf(this, x) + this.LogConstant );
        end%


        function value = get.Std(this)
            value = sqrt(this.Var);
        end%


        function this = set.Std(this, value)
            this.Var = value.^2;
        end%
    end
end
