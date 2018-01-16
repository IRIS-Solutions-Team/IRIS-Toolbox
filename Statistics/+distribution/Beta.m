% Beta  Beta distribution object
%
%
% Beta methods:
%
% __Constructors__
%
%   distribution.Beta.fromABeta - Beta distribution from parameters A and B
%   distribution.Beta.fromMeanVar - Beta distribution from mean and variance
%   distribution.Beta.fromMeanStd - Beta distribution from mean and std deviation
%   distribution.Beta.fromModeVar - Beta distribution from mode and variance
%   distribution.Beta.fromModeStd - Beta distribution from mode and std deviation
%
%
% __Distribution Properties__
%
% These properties are directly accessible through the distribution object,
% followed by a dot and the name of a property.
%
%   A - Parameter A of Beta distribution
%   Beta - Parameter B of Beta distribution
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

classdef Beta < distribution.Abstract
    properties (SetAccess=protected)
        % A  Parameter A of Beta distribution
        A = NaN       

        % B  Parameter B of Beta distribution
        B = NaN        
    end


    properties (SetAccess=protected, Hidden)
        Constant = NaN    % Integration constant
    end


    properties (Constant)
        MAX_A = 1e10;
    end


    methods
        function this = Beta(varargin)
            this = this@distribution.Abstract(varargin{:});
            this.Name = 'Beta';
            this.Lower = 0;
            this.Upper = 1;
        end


        function y = logPdf(this, x)
            y = zeros(size(x));
            indexInDomain = inDomain(this, x);
            x = x(indexInDomain);
            y(indexInDomain) = (this.A-1)*log(x) + (this.B-1)*log(1-x);
            y(~indexInDomain) = -Inf;
        end


        function y = pdf(this, x)
            y = zeros(size(x));
            indexInDomain = inDomain(this, x);
            x = x(indexInDomain);
            y(indexInDomain) = x.^(this.A-1).*(1-x).^(this.B-1) * this.Constant;
        end


        function y = info(this, x)
            y = nan(size(x));
            indexInDomain = inDomain(this, x);
            x = x(indexInDomain);
            y(indexInDomain) = (this.B - 1)./(x - 1).^2 + (this.A - 1)./x.^2;
        end
    end


    methods (Access=protected)
        function populateParameters(this)
            if ~isfinite(this.Mean)
                this.Mean = this.A / (this.A + this.B);
            end
            if ~isfinite(this.Mode)
                if this.A>1 && this.B>1
                    this.Mode = (this.A - 1)/(this.A + this.B - 2);
                else
                    this.Mode = NaN;
                end
            end
            if ~isfinite(this.Var)
                this.Var = this.A * this.B / ( (this.A + this.B)^2 * (this.A + this.B + 1) );
            end
            if ~isfinite(this.Std)
                this.Std = sqrt(this.Var);
            end
            this.Constant = 1./beta(this.A, this.B);
        end


        function ABFromMeanVar(this)
            this.A = (1-this.Mean)*this.Mean^2/this.Var - this.Mean;
            this.B = this.A*(1/this.Mean - 1);
        end


        function ABFromModeVar(this)
            Mode = this.Mode;
            Var = this.Var;
            B = @(A) (A-1)/Mode - A + 2;
            f = @(A) Var*(A + B(A))^2*(A + B(A) + 1) - A*B(A);
            this.A = fzero(f, [1+eps( ), this.MAX_A]);
            this.B = B(this.A);
        end
    end


    methods (Static)
        function this = fromAB(varargin)
            % distribution.Beta.fromAB  Beta distribution from parameters A and B
            this = distribution.Beta( );
            [this.A, this.B] = varargin{1:2};
            populateParameters(this);
        end


        function this = fromMeanVar(varargin)
            % distribution.Beta.fromMeanVar  Beta distribution from mean and variance
            this = distribution.Beta( );
            [this.Mean, this.Var] = varargin{1:2};
            ABFromMeanVar(this);
            populateParameters(this);
        end


        function this = fromMeanStd(varargin)
            % distribution.Beta.fromMeanStd  Beta distribution from mean and std deviation
            this = distribution.Beta( );
            [this.Mean, this.Std] = varargin{1:2};
            this.Var = this.Std.^2;
            ABFromMeanVar(this);
            populateParameters(this);
        end


        function this = fromModeVar(varargin)
            % distribution.Beta.fromModeVar  Beta distribution from mode and variance
            this = distribution.Beta( );
            [this.Mode, this.Var] = varargin{1:2};
            ABFromModeVar(this);
            populateParameters(this);
        end


        function fromModeStd(varargin)
            % distribution.Beta.fromModeStd  Beta distribution from mode and std deviation
            [this.Mode, this.Std] = varargin{1:2};
            this.Var = this.Std^2;
            ABFromModeVar(this);
            populateParameters(this);
        end
    end
end
