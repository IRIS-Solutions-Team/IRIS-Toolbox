% InvGamma  Inverse Gamma distribution object
%
%
% Inverse Gamma methods:
%
% __Constructors__
%
% The following are static constructors and need to be called with
% `distribution.InvGamma.` preceding their names.
%
%   fromShapeScale - Inverse Gamma distribution from shape and scale parameters
%   fromAlphaBeta - Inverse Gamma distribution from alpha and beta parameters of underlying Gamma distribution
%   fromMeanVar - Inverse Gamma distribution from mean and variance
%   fromMeanStd - Inverse Gamma distribution from mean and std deviation
%   fromModeVar - Inverse Gamma distribution from mode and variance
%   fromModeStd - Inverse Gamma distribution from mode and std deviation
%
%
% __Distribution Properties__
%
% These properties are directly accessible through the distribution object,
% followed by a dot and the name of a property.
%
%   Alpha - (scale) parameter of underlying Gamma distribution
%   Beta - (shape) parameter of underlying Gamma distribution
%   Lower - Lower bound of distribution domain
%   Upper - Upper bound of distribution domain
%   Mean - Mean (expected value) of distribution
%   Var - Variance of distribution
%   Std - Standard deviation of distribution
%   Mode - Mode of distribution
%   Median - Median of distribution
%   Location - Location parameter of distribution
%   Shape - Shape parameter of distribution
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

classdef InvGamma < distribution.Abstract
    properties (SetAccess=protected)
        % Alpha (scale) parameter of underlying Gamma distribution
        Alpha       

        % Beta (shape) parameter of underlying Gamma distribution
        Beta        
    end


    properties (SetAccess=protected, Hidden)
        Constant    % Integration constant
    end


    properties (Constant, Hidden)
        MAX_ALPHA = 1e10;
    end


    methods
        function this = InvGamma(varargin)
            this = this@distribution.Abstract(varargin{:});
            this.Name = 'InvGamma';
            this.Lower = 0;
            this.Upper = Inf;
            this.Location = 0;
        end


        function y = logPdf(this, x)
            y = zeros(size(x));
            indexInDomain = inDomain(this, x);
            x = x(indexInDomain);
            y(indexInDomain) = (-this.Alpha - 1)*log(x) - 1./(this.Beta * x);
            y(~indexInDomain) = -Inf;
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


    methods (Access=protected)
        function populateParameters(this)
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


        function alphaBetaFromMeanVar(this)
            this.Alpha = this.Mean^2/this.Var + 2;
            this.Beta = 1./(this.Mean*(this.Alpha-1));
        end


        function alphaBetaFromModeVar(this)
            k = this.Var/this.Mode^2;
            obj = @(Alpha) (Alpha+1)^2 - k*(Alpha-1)^2*(Alpha-2);
            this.Alpha = fzero(obj, [2+eps(), this.MAX_ALPHA]);
            this.Beta = 1./(this.Mode * (this.Alpha+1));
        end
    end


    methods (Static)
        function this = fromShapeScale(varargin)
            % fromShapeScale  Inverse Gamma distribution from shape and scale parameters
            this = distribution.InvGamma( );
            [this.Shape, this.Scale] = varargin{1:2};
            this.Alpha = this.Shape;
            this.Beta = 1/this.Scale;
            populateParameters(this);
        end


        function this = fromAlphaBeta(varargin)
            % fromAlphaBeta  Inverse Gamma distribution from alpha and beta parameters of underlying Gamma distribution
            this = distribution.InvGamma( );
            [this.Alpha, this.Beta] = varargin{1:2};
            populateParameters(this);
        end


        function this = fromMeanVar(varargin)
            % fromMeanVar  Inverse Gamma distribution from mean and variance
            this = distribution.InvGamma( );
            [this.Mean, this.Var] = varargin{1:2};
            alphaBetaFromMeanVar(this);
            populateParameters(this);
        end


        function this = fromMeanStd(varargin)
            % fromMeanStd  Inverse Gamma distribution from mean and std deviation
            this = distribution.InvGamma( );
            [this.Mean, this.Std] = varargin{1:2};
            this.Var = this.Std^2;
            alphaBetaFromMeanVar(this);
            populateParameters(this);
        end


        function this = fromModeVar(varargin)
            % fromModeVar  Inverse Gamma distribution from mode and variance
            this = distribution.InvGamma( );
            [this.Mode, this.Var] = varargin{1:2};
            alphaBetaFromModeVar(this);
            populateParameters(this);
        end


        function this = fromModeStd(varargin)
            % fromModeStd  Inverse Gamma distribution from mode and std deviation
            this = distribution.InvGamma( );
            [this.Mode, this.Std] = varargin{1:2};
            this.Var = this.Std^2;
            alphaBetaFromModeVar(this);
            populateParameters(this);
        end
    end
end
