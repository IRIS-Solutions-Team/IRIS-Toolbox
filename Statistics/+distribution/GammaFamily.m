classdef (Abstract) GammaFamily ...
    < matlab.mixin.Copyable 

    methods
        function [y, inxInDomain] = logPdfInDomain(this, x)
            y = (this.Alpha - 1)*log(x) - x/this.Beta;
        end%


        function y = infoInDomain(this, x)
            x2 = x.^2;
            y = (this.Alpha - 1) ./ x2;
        end%


        function y = sample(this, varargin)
            y = gamrnd(this.Alpha, this.Beta, varargin{:});
        end%


        function populateParameters(this)
            if ~validate.numericScalar(this.Mean) || ~isfinite(this.Mean)
                this.Mean = this.Alpha*this.Beta;
            end
            if ~validate.numericScalar(this.Mode) || ~isfinite(this.Mode)
                this.Mode = max(0, (this.Alpha-1)*this.Beta);
            end
            if ~validate.numericScalar(this.Var) || ~isfinite(this.Var)
                this.Var = this.Alpha * this.Beta.^2;
            end
            this.Shape = this.Alpha;
            this.Scale = this.Beta;
            this.LogConstant = -(this.Alpha*log(this.Beta) + gammaln(this.Alpha));
        end%
    end
end

