classdef (Abstract) GammaFamily ...
    < matlab.mixin.Copyable 

    methods
        function y = logPdfInDomain(this, x)
            y = (this.Alpha - 1)*log(x) - x/this.Beta;
        end%


        function y = infoInDomain(this, x)
            x2 = x.^2;
            y = (this.Alpha - 1) ./ x2;
        end%
    end


    methods (Access=protected)
        function y = sampleIris(this, dim)
            y = distribution.GammaFamily.sampleMarsagliaTsang( ...
                [this.Alpha, this.Beta], dim ...
            );
        end%
                        

        function y = sampleStats(this, dim)
            y = gamrnd(this.Alpha, this.Beta, dim);
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
        function y = sampleMarsagliaTsang(alphaBeta, varargin)
            if numel(varargin)==1
                dim = varargin{1};
            else
                dim = [varargin{:}];
            end
            if numel(dim)==1
                dim = [dim, dim];
            end
            alpha = alphaBeta(1);
            if alphaBeta(1)<1
                alpha = 1 + alpha;
            end
            beta = alphaBeta(2);
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
            if alphaBeta(1)<1
                y = y .* (rand(size(y))).^(1/alphaBeta(1));
            end
        end%
    end
end

