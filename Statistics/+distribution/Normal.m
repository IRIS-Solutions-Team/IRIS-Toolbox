% Normal  Function proportional to log density of Normal distribution
%
% __Syntax__
%
%     F = distribution.Normal('MeanStd', Mean, Std)
%     F = distribution.Normal('MeanVar', Mean, Var)
%
%
% __Input Arguments__
%
% * `Mean` [ numeric ] - Mean of Normal distribution.
%
% * `Std` [ numeric ] - Std deviation of Normal distribution.
%
% * `Var` [ numeric ] - Variance of Normal distribution.
%
%
% __Output Arguments__
%
% * `F` [ function_handle ] - Function handle returning a value
% proportional to the log density of the Normal distribution, and giving
% access to other characteristics of the Normal distribution.
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

classdef Normal < distribution.Abstract
    properties (Constant)
        PDF_CONSTANT = 1/sqrt(2*pi);
    end


    methods
        function this = Normal(varargin)
            this = this@distribution.Abstract(varargin{:});
            this.Name = 'Normal';
            this.Shape = NaN;
            if nargin==0
                return
            end
            parameterization = varargin{1};
            if strcmpi(parameterization, 'MeanStd')
                fromMeanStd(this, varargin{2:3});
            elseif strcmpi(parameterization, 'MeanVar')
                fromMeanVar(this, varargin{2:3})
            else
                throw( ...
                    exception.Base('Distribution:InvalidParameterization', 'error'), ...
                    this.Name, parameterization ...
                );
            end
            this.Location = this.Mean;
            this.Scale = this.Std;
            this.Mode = this.Mean;
            this.Median = this.Mean;
        end


        function fromMeanStd(this, varargin)
            [this.Mean, this.Std] = varargin{1:2};
            this.Var = this.Std.^2;
        end


        function fromMeanVar(this, varargin)
            [this.Mean, this.Var] = varargin{1:2};
            this.Std = sqrt(this.Var);
        end


        function y = logPdf(this, x)
            y = -0.5*( (x - this.Mean).^2 ./ this.Var );
        end


        function indexInDomain = inDomain(this, x)
            indexInDomain = true(size(x)); 
        end


        function y = pdf(this, x)
            y = logPdf(this, x);
            y = this.PDF_CONSTANT./this.Std * exp(y);
        end


        function y = info(this, x)
            y = 1/this.Var;
            y = y(ones(size(x)));
        end
    end
end
