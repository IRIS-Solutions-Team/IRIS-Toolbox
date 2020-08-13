classdef ParameterizedArmani ...
    < Armani

    properties
        NumParameters (1, 1) double = 0
        ParameterizedAR = 1
        ParameterizedMA = 1
    end


    methods
        function this = ParameterizedArmani(numParameters, parameterizedAR, parameterizedMA, tolerance)
            if nargin>=1
                this.NumParameters = numParameters;
            end
            if nargin>=2
                this.ParameterizedAR = parameterizedAR;
            end
            if nargin>=3
                this.ParameterizedMA = parameterizedMA;
            end
            if nargin>=4
                this.Tolerance = tolerance;
            end
            this = update(this, zeros(1, numParameters));
        end%


        function this = update(this, p)
            if numel(p)~=this.NumParameters
                throw(exception.Base([
                    "ParameterizedArmani:InvalidNumParameters"
                    "Invalid number of parameters to update the ParameterizedArmani object. "
                    "The number of parameters required is %g but only %g are being passed in. "
                ], 'error'), this.NumParameters, numel(p));
            end
            if isa(this.ParameterizedAR, 'function_handle')
                this.AR = this.ParameterizedAR(p);
            end
            if isa(this.ParameterizedMA, 'function_handle')
                this.MA = this.ParameterizedMA(p);
            end
        end%    
    end
end

