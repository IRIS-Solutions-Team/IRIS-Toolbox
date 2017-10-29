% gamma  Function proportional to log density of Gamma distribution
%
% __Syntax__
%
%     F = distribution.Gamma('AlphaBeta', Alpha, Beta)
%     F = distribution.Gamma('MeanStd', Mean, Std)
%     F = distribution.Gamma('MeanVar', Mean, Var)
%
%
% __Input Arguments__
%
% * `Alpha` [ numeric ] - Shape parameter of Gamma distribution.
%
% * `Beta [ numeric ] - Scale parameter of Gamma distribution.
%
% * `Mean` [ numeric ] - Mean of Gamma distribution.
%
% * `Std` [ numeric ] - Std deviation of Gamma distribution.
%
% * `Var` [ numeric ] - Variance of Gamma distribution.
%
%
% __Output Arguments__
%
% * `F` [ function_handle ] - Function handle returning a value
% proportional to the log density of the Gamma distribution, and giving
% access to other characteristics of the Gamma distribution.
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

classdef Gamma < distribution.Abstract
    properties (SetAccess=protected)
        Alpha
        Beta
    end


    methods
        function this = Gamma(varargin)
            this = this@distribution.Abstract(varargin{:});
            this.Name = 'Gamma';
            this.Location = NaN;
            this.Median = NaN;
            if nargin==0
                return
            end
            parameterization = varargin{1};
            if strcmpi(parameterization, 'MeanStd')
                fromMeanStd(this, varargin{2:3});
            elseif strcmpi(parameterization, 'MeanVar')
                fromMeanVar(this, varargin{2:3});
            elseif strcmpi(parameterization, 'AlphaBeta')
                fromAlphaBeta(this, varargin{2:3})
            else
                throw( ...
                    exception.Base('Distribution:InvalidParameterization', 'error'), ...
                    this.Name, parameterization ...
                );
            end
            this.Mode = max(0, (this.Alpha-1)*this.Beta);
            this.Shape = this.Alpha;
            this.Scale = this.Beta;
        end


        function fromAlphaBeta(this, varargin)
            [this.Alpha, this.Beta] = varargin{1:2};
            this.Mean = this.Alpha * this.Beta;
            this.Var = this.Alpha * this.Beta.^2;
            this.Std = sqrt(this.Var);
        end


        function fromMeanStd(this, varargin)
            [this.Mean, this.Std] = varargin{1:2};
            this.Var = this.Std.^2;
            alphaBetaFromMeanVar(this);
        end


        function fromMeanVar(this, varargin)
            [this.Mean, this.Var] = varargin{1:2};
            this.Std = sqrt(this.Var);
            alphaBetaFromMeanVar(this);
        end


        function alphaBetaFromMeanVar(this)
            this.Beta = this.Var / this.Mean;
            this.Alpha = this.Mean / this.Beta;
        end


        function y = logPdf(this, x)
            y = zeros(size(x));
            indexInDomain = inDomain(this, x);
            x = x(indexInDomain);
            a = this.Alpha;
            b = this.Beta;
            y(indexInDomain) = (a - 1)*log(x) - x/b;
            y(~indexInDomain) = -Inf;
        end


        function indexInDomain = inDomain(this, x)
            indexInDomain = x>0;
        end


        function y = pdf(this, x)
            y = zeros(size(x));
            indexInDomain = inDomain(this, x);
            x = x(indexInDomain);
            a = this.Alpha;
            b = this.Beta;
            y(indexInDomain) = x.^(a-1).*exp(-x/b) / (b^a*gamma(a));
        end


        function y = info(this, x)
            y = nan(size(x));
            indexInDomain = inDomain(this, x);
            x = x(indexInDomain);
            y(indexInDomain) = (this.Alpha - 1) / x.^2;
        end
    end
end
