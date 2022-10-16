% Armani  Utilities for univariate non-infinite (aka finite) ARMA models

classdef Armani

    properties
% AR  Monic polynomial in lag operator describing the AR component
        AR (1, :) = 1

% MA  Monic polynomial in lag operator describing the MA component
        MA (1, :) = 1

% Tolerance  Tolerance level for zeros in the AR and MA polynomials
        Tolerance (1, 1) double = 1e-14


% Parameters  Empty array
% >=R2019b
%{
        Parameters (1, :, :) double = double.empty(1, 0, 1)
%}
% >=R2019b


% <=R2019a
%(
        Parameters double = double.empty(1, 0, 1)
%)
% <=R2019a
    end


    properties
% IsIdentity  True if both AR and MA parts are 1
        IsIdentity
    end


    methods
        function this = Armani(AR, MA, tolerance)
            if nargin==0
                return
            end
            if nargin>=1
                this.AR = AR;
            end
            if nargin>=2
                this.MA = MA;
            end
            if nargin>=3
                this.Tolerance = tolerance;
            end
        end%


        function this = toFiniteMA(this, length)
            if isequal(this.AR, 1)
                return
            end
            this.MA = Armani.divide(this.MA, this.AR, length);
            this.AR = 1;
        end%


        function this = toFiniteAR(this, length)
            if isequal(this.MA, 1)
                return
            end
            this.AR = Armani.divide(this.AR, this.MA, length);
            this.MA = 1;
        end%


        function this = set.AR(this, value)
            this.AR = Armani.toMinimumMonic(value, this.Tolerance);
        end%


        function this = set.MA(this, value)
            this.MA = Armani.toMinimumMonic(value, this.Tolerance);
        end%


        function this = mtimes(this, that)
            this.AR = conv(this.AR, that.AR);
            this.MA = conv(this.MA, that.MA);
        end%


        function this = inv(this)
            [this.AR, this.MA] = deal(this.MA, this.AR);
        end%


        function out = cov(this, length)
            s = sqrtCov(this, length);
            out = s * s';
        end%


        function out = sqrtCov(this, length)
            s = Armani.divide(this.MA, this.AR, length);
            if numel(s)<length
                s(end+1:length) = 0;
            end
            out = tril(toeplitz(s));
        end%


        function varargout = reconstruct(this, varargin)
            [varargout{1:nargout}] = filter(this, varargin{:});
        end%


        function varargout = deconstruct(this, varargin)
            [varargout{1:nargout}] = filter(inv(this), varargin{:});
        end%


        function x = filter(this, x, varargin)
            %(
            if isequal(this.AR, 1) && isequal(this.MA, 1)
                return
            end
            if isnumeric(x)
                x = filter(this.MA, this.AR, x, varargin{:});
                return
            end
            if isa(x, 'Series')
                x.Data = filter(this.MA, this.AR, x.Data, varargin{:});
                return
            end
            exception.error([
                "Armani"
                "Input data need to be either columwise oriented numeric vectors "
                "or time series. "
            ]);
            %)
        end%


        function M = filterMatrix(this, length)
            if isequal(this.AR, 1)
                ma = this.MA;
                if numel(ma)<length
                    ma(end+1:length) = 0;
                elseif numel(ma)>length
                    ma = ma(1:length);
                end
            else
                ma = Armani.divide(this.MA, this.AR, length);
            end
            M = tril(toeplitz(ma));
        end%


        function this = update(this, varargin)
        end%


        function numVariants = countVariants(this)
            numVariants = size(this.Parameters, 3);
        end%


        function this = alter(this, new)
            numVariants = countVariants(this);
            if new<numVariants
                this.Parameters = this.Parameters(1, :, 1:new);
            elseif new>numVariants
                this.Parameters(1, :, end+1:new) ...
                    = repmat(this.Parameters(1, :, end), 1, 1, new-numVariants);
            end
        end%


        function this = reset(this)
            this.Parameters(:, :, :) = NaN;
        end%


        function value = get.IsIdentity(this)
            value = isequal(this.AR, 1) && isequal(this.MA, 1);
        end%
    end            


    methods (Static)
        function this = fromParamArmani(pa, variant, varargin)
            gamma = pa.Parameters(1, :, variant);
            pa = update(pa, gamma);
            this = Armani(pa.AR, pa.MA, varargin{:});
        end%


        function c = divide(numerator, denominator, length)
            %(
            if isequal(denominator, 1)
                c = numerator;
                return
            end
            c = filter(numerator, denominator, [1, zeros(1, length-1)]);
            %)
        end%


        function polyn = toMinimumMonic(polyn, tolerance)
            %(
            if nargin<2
                tolerance = 0;
            end
            if isempty(polyn)
                polyn = 1;
                return
            end
            if iscell(polyn) && numel(polyn)==1
                polyn = polyn{1};
            end
            if iscell(polyn)
                polyn = Armani.conv(polyn{:});
            else
                polyn = reshape(polyn, 1, [ ]);
                if any(imag(polyn)~=0)
                    polyn = Armani.polynFromLags(polyn);
                end
            end
            if isequal(polyn, 1)
                return
            end
            if polyn(1)~=1
                polyn = polyn / polyn(1);
            end
            absPoly = abs(polyn);
            if absPoly(end)<=tolerance
                polyn = polyn(1:find(absPoly>tolerance, 1, 'last')); 
            end
            %)
        end%


        function polyn = polynFromLags(lags)
            %(
            lags = reshape(lags, 1, [ ]);
            shift = imag(lags);
            coeff = real(lags);
            if any(shift>0) || any(shift~=round(shift))
                throw(exception.Base([
                    "Armani:InvalidLagSpecification"
                    "Lag specification of a polynominal needs to have "
                    "its imaginary components all non-positive integers. "
                ], 'error'));
            end
            maxLag = -min(shift);
            polyn = zeros(1, maxLag+1);
            polyn(1-shift) = coeff;
            %)
        end%


        function polyn = conv(varargin)
            %(
            polyn = 1;
            for i = 1 : nargin
                add = reshape(varargin{i}, 1, [ ]);
                if any(imag(add)~=0)
                    add = Armani.polynFromLags(add);
                end
                polyn = conv(polyn, add);
            end
            %)
        end%
    end
end

