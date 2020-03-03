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
            [dim, sampler] = distribution.Abstract.determineSampler(varargin{:});
            if strcmpi(sampler, 'Iris')
                y = distribution.GammaFamily.sampleMarsagliaTsang([this.Alpha, this.Beta], varargin{1:end-1});
            else
                y = gamrnd(this.Alpha, this.Beta, dim);
            end
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




    methods (Static)
        function y = sampleMarsagliaTsang(parameters, varargin)
            if numel(varargin)==1
                dim = varargin{1};
            else
                dim = [varargin{:}];
            end
            if numel(dim)==1
                dim = [dim, dim];
            end
            alpha = parameters(1);
            if parameters(1)<1
                alpha = 1 + alpha;
            end
            beta = parameters(2);
            y = nan(dim);
            d = alpha-1/3;
            c = 1/sqrt(9*d);
            for i = 1 : numel(y)
                while true
                    z = randn( );
                    if z<=-1/c
                        continue
                    end
                    u = rand( );
                    V = (1 + c*z)^3;
                    if log(u)<(0.5*z^2 + d - d*V + d*log(V))
                        y(i) = d*V;
                        break
                    end
                end
            end
            if beta~=1
                y = y * beta;
            end
            if parameters(1)<1
                y = y .* (rand(size(y))).^(1/parameters(1));
            end
        end%
    end
end

