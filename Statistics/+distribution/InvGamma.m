% gamma  Inverse Gamma distribution object
%
% __Syntax__
%
%     F = distribution.InvGamma('ShapeScale', Shape, Scale)
%     F = distribution.InvGamma('AlphaBeta', Alpha, Beta)
%     F = distribution.InvGamma('MeanVar', Mean, Var)
%     F = distribution.InvGamma('MeanStd', Mean, Std)
%
%
% __Input Arguments__
%
% * `Alpha` [ numeric ] - Shape parameter Alpha of the underlying Gamma
% distribution.
%
% * `Beta [ numeric ] - Scale parameter Beta of of the underlying Gamma
% distribution.
%
% * `Mean` [ numeric ] - Mean of Gamma distribution.
%
% * `Var` [ numeric ] - Variance of Gamma distribution.
%
% * `Std` [ numeric ] - Std deviation of Gamma distribution.
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

classdef InvGamma < distribution.Abstract
    properties (SetAccess=protected)
        Alpha       % Alpha parameter of underlying Gamma
        Beta        % Beta parameter of underlying Gamma
        Constant    % Integration constant
    end


    methods
        function this = InvGamma(varargin)
            this = this@distribution.Abstract(varargin{:});
            this.Name = 'InvGamma';
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
            elseif strcmpi(parameterization, 'ShapeScale')
                fromShapeScale(this, varargin{2:3});
            else
                throw( ...
                    exception.Base('Distribution:InvalidParameterization', 'error'), ...
                    this.Name, parameterization ...
                );
            end
            this.Mode = 1/(this.Beta*(this.Alpha+1));
            if ~isfinite(this.Mean) && this.Alpha>1
                this.Mean = 1/(this.Beta*(this.Alpha-1));
            end
            if ~isfinite(this.Var) && this.Alpha>2
                this.Var = this.Mean^2 / (this.Alpha-2);
            end
            if ~isfinite(this.Std)
                this.Std = sqrt(this.Var);
            end
            if ~isfinite(this.Shape)
                this.Shape = this.Alpha;
            end
            if ~isfinite(this.Scale)
                this.Scale = 1./this.Beta;
            end
            this.Constant = 1./(this.Beta^this.Alpha * gamma(this.Alpha));
        end


        function fromShapeScale(this, varargin)
            [this.Shape, this.Scale] = varargin{1:2};
            this.Alpha = this.Shape;
            this.Beta = 1/this.Scale;
        end


        function fromAlphaBeta(this, varargin)
            [this.Alpha, this.Beta] = varargin{1:2};
        end


        function fromMeanStd(this, varargin)
            [this.Mean, this.Std] = varargin{1:2};
            this.Var = this.Std^2;
            alphaBetaFromMeanVar(this);
        end


        function fromMeanVar(this, varargin)
            [this.Mean, this.Var] = varargin{1:2};
            this.Std = sqrt(this.Var);
            alphaBetaFromMeanVar(this);
        end


        function alphaBetaFromMeanVar(this)
            this.Alpha = this.Mean^2/this.Var + 2;
            this.Beta = 1./(this.Mean*(this.Alpha-1));
        end


        function y = logPdf(this, x)
            y = zeros(size(x));
            indexInDomain = inDomain(this, x);
            x = x(indexInDomain);
            y(indexInDomain) = (-this.Alpha - 1)*log(x) - 1./(this.Beta * x);
            y(~indexInDomain) = -Inf;
        end


        function indexInDomain = inDomain(this, x)
            indexInDomain = x>0;
        end


        function y = pdf(this, x)
            y = zeros(size(x));
            indexInDomain = inDomain(this, x);
            x = x(indexInDomain);
            y(indexInDomain) = x.^(-this.Alpha-1).*exp(-1./(this.Beta * x)) * this.Constant;
        end


        function y = info(this, x)
            y = nan(size(x));
            indexInDomain = inDomain(this, x);
            x = x(indexInDomain);
            x2 = x(indexInDomain).^2;
            x3 = x(indexInDomain).^3;
            y(indexInDomain) = (-this.Alpha - 1)./x2 + 2./(this.Beta * x3);
        end
    end
end
