% Type `web +diistribution/@Beta/index.md` for help on this class
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

classdef Beta ...
    < distribution.Distribution

    properties (SetAccess=protected)
        % A  Parameter A of Beta distribution
        A = NaN       

        % B  Parameter B of Beta distribution
        B = NaN        
    end


    properties (Constant)
        MAX_A = 1e10;
    end


    methods
        function this = Beta(varargin)
            this = this@distribution.Distribution(varargin{:});
            this.Name = 'Beta';
            this.Domain = [0, 1];
            this.Location = 0;
        end%


        function y = logPdfInDomain(this, x)
            y = (this.A-1)*log(x) + (this.B-1)*log(1-x);
        end%


        function y = infoInDomain(this, x)
            y = (this.B - 1)./(x - 1).^2 + (this.A - 1)./x.^2;
        end%
    end
        
        
    methods (Access=protected)
        function y = sampleIris(this, dim)
            y = nan(dim);
            inxValid = isfinite(y);
            while any(~inxValid)
                num = nnz(~inxValid);
                y1 = distribution.GammaFamily.sampleMarsagliaTsang([this.A, 1], num, 1);
                y2 = distribution.GammaFamily.sampleMarsagliaTsang([this.B, 1], num, 1);
                y(~inxValid) = y1 ./ (y1 + y2);
                inxValid = isfinite(y);
            end
        end%


        function y = sampleStats(this, dim)
            y = betarnd(this.A, this.B, dim);
        end%


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
            this.LogConstant = -betaln(this.A, this.B);
        end%


        function ABFromMeanVar(this)
            this.A = (1-this.Mean)*this.Mean^2/this.Var - this.Mean;
            this.B = this.A*(1/this.Mean - 1);
        end%


        function ABFromModeVar(this)
            Mode = this.Mode;
            Var = this.Var;
            B = @(A) (A-1)/Mode - A + 2;
            f = @(A) Var*(A + B(A))^2*(A + B(A) + 1) - A*B(A);
            this.A = fzero(f, [1+eps( ), this.MAX_A]);
            this.B = B(this.A);
        end%
    end


    methods (Static)
        function this = fromAB(varargin)
            % fromAB  Beta distribution from parameters A and B
            this = distribution.Beta( );
            [this.A, this.B] = varargin{1:2};
            populateParameters(this);
        end%


        function this = fromMeanVar(varargin)
            % fromMeanVar  Beta distribution from mean and variance
            this = distribution.Beta( );
            [this.Mean, this.Var] = varargin{1:2};
            ABFromMeanVar(this);
            populateParameters(this);
        end%


        function this = fromMeanStd(varargin)
            % fromMeanStd  Beta distribution from mean and std deviation
            this = distribution.Beta( );
            [this.Mean, this.Std] = varargin{1:2};
            this.Var = this.Std.^2;
            ABFromMeanVar(this);
            populateParameters(this);
        end%


        function this = fromModeVar(varargin)
            % fromModeVar  Beta distribution from mode and variance
            this = distribution.Beta( );
            [this.Mode, this.Var] = varargin{1:2};
            ABFromModeVar(this);
            populateParameters(this);
        end%


        function fromModeStd(varargin)
            % fromModeStd  Beta distribution from mode and std deviation
            [this.Mode, this.Std] = varargin{1:2};
            this.Var = this.Std^2;
            ABFromModeVar(this);
            populateParameters(this);
        end%
    end
end
