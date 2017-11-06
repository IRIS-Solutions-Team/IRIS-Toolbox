% Uniform  Function proportional to log density of Uniform distribution
%
% __Syntax__
%
%     F = distribution.Uniform('MeanStd', Mean, Std)
%     F = distribution.Uniform('MeanVar', Mean, Var)
%
%
% __Input Arguments__
%
% * `Mean` [ numeric ] - Mean of Uniform distribution.
%
% * `Std` [ numeric ] - Std deviation of Uniform distribution.
%
% * `Var` [ numeric ] - Variance of Uniform distribution.
%
%
% __Output Arguments__
%
% * `F` [ function_handle ] - Function handle returning a value
% proportional to the log density of the Uniform distribution, and giving
% access to other characteristics of the Uniform distribution.
%
%
% __Description__
%
% See [help on the `distribution` package](distribution/Contents) for details on
% using the function handle `F`.
%
%
% Example
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

classdef Uniform < distribution.Abstract
    properties (SetAccess=protected)
        Lower = NaN
        Upper = NaN
        Pdf = NaN
    end


    methods
        function this = Uniform(varargin)
            this = this@distribution.Abstract(varargin{:});
            this.Name = 'Uniform';
            if nargin==0
                return
            end
            parameterization = varargin{1};
            if strcmpi(parameterization, 'LowerUpper')
                fromLowerUpper(this, varargin{2:3});
            elseif strcmpi(parameterization, 'MeanStd')
                fromMeanStd(this, varargin{2:3})
            elseif strcmpi(parameterization, 'MeanVar')
                fromMeanVar(this, varargin{2:3})
            elseif strcmpi(parameterization, 'MedianStd')
                fromMedianStd(this, varargin{2:3})
            elseif strcmpi(parameterization, 'MedianVar')
                fromMedianVar(this, varargin{2:3})
            else
                throw( ...
                    exception.Base('Distribution:InvalidParameterization', 'error'), ...
                    this.Name, parameterization ...
                );
            end
            this.Pdf = 1./(this.Upper - this.Lower);
            if ~isfinite(this.Mean)
                this.Mean = (this.Lower + this.Upper)/2;
            end
            if ~isfinite(this.Median)
                this.Median = (this.Lower + this.Upper)/2;
            end
            if ~isfinite(this.Var)
                this.Variance = (this.Upper - this.Lower)^2/12;
            end
            if ~isfinite(this.Std)
                this.Std = sqrt(this.Var);
            end
        end


        function fromLowerUpper(this, varargin)
            [this.Lower, this.Upper] = varargin{:};
            assert( ...
                this.Lower<this.Upper, ...
                exception.Base('distribution:Uniform:LowerUpperBounds', 'error') ...
            );
        end


        function fromMeanVar(this, varargin)
            [this.Mean, this.Var] = varargin{1:2};
            this.Std = sqrt(this.Var);
            fromMeanStd(this);
        end


        function fromMeanStd(this, varargin)
            if nargin>1
                [this.Mean, this.Std] = varargin{1:2};
            end
            this.Upper = sqrt(12)*this.Std/2 + this.Mean;
            this.Lower = 2*this.Mean - this.Upper;
        end


        function fromMedianVar(this, varargin)
            [this.Median, this.Var] = varargin{1:2};
            this.Mean = this.Median;
            this.Std = sqrt(this.Var);
            fromMeanStd(this);
        end


        function fromMedianStd(this, varargin)
            [this.Median, this.Std] = varargin{1:2};
            this.Mean = this.Median;
            fromMeanStd(this);
        end


        function y = logPdf(this, x)
            indexInDomain = inDomain(this, x);
            y = zeros(size(x));
            y(indexInDomain) = 0;
            y(~indexInDomain) = -Inf;
        end


        function indexInDomain = inDomain(this, x)
            indexInDomain = x>=this.Lower & x<=this.Upper;
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
end
