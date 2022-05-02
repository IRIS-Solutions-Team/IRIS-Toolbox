classdef ParamArmani ...
    < Armani

    properties
        NumParameters (1, 1) double = 0
        ParameterizedAR = 1
        ParameterizedMA = 1
    end

    methods
        function this = ParamArmani(numParameters, parameterizedAR, parameterizedMA, tolerance)
            if nargin>=1
                this.NumParameters = numParameters;
                this.Parameters = nan(1, numParameters, 1);
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
                    "ParamArmani:InvalidNumParameters"
                    "Invalid number of parameters to update the ParamArmani object. "
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


    methods (Static)
        function this = fromArmani(armani)
            this = ParamArmani(0, armani.AR, armani.MA);
        end%


        function this = fromString(input)
            preserveInput = input;
            input = replace(string(input), " ", "");
            input = erase(input, "#");
            if startsWith(input, "{") && endsWith(input, "}")
                input = extractAfter(input, 1);
                input = extractBefore(input, strlength(input));
            end
            temp = textual.splitArguments(input);
            if numel(temp)~=2
                hereThrowError();
            end
            ar = temp(1);
            ma = temp(2);
            if contains(ar, "]*[")
                ar = replace(ar, "]*[", "],[");
                ar = "{" + ar + "}";
            end
            if contains(ma, "]*[")
                ma = replace(ma, "]*[", "],[");
                ma = "{" + ma + "}";
            end
            ar = char(ar);
            ma = char(ma);
            numArParameters = nnz(ar=='@');
            numMaParameters = nnz(ma=='@');
            numParameters = 0;
            if numArParameters==0
                ar = eval(ar);
            else
                pos = find(ar=='@', 1);
                while ~isempty(pos)
                    numParameters = numParameters + 1;
                    ar = [ar(1:pos-1), sprintf('p(%g)', numParameters), ar(pos+1:end)];
                    pos = find(ar=='@', 1);
                end
                ar = str2func(['@(p)', ar]);
            end
            if numMaParameters==0
                ma = eval(ma);
            else
                pos = find(ma=='@', 1);
                while ~isempty(pos)
                    numParameters = numParameters + 1;
                    ma = [ma(1:pos-1), sprintf('p(%g)', numParameters), ma(pos+1:end)];
                    pos = find(ma=='@', 1);
                end
                ma = str2func(['@(p)', ma]);
            end
            this = ParamArmani(numArParameters+numMaParameters, ar, ma);

            return

                function hereThrowError()
                    exception.error([
                        "ParamArmani:InvalidInputString"
                        "This is not a valid input string for an ParamArmani object: %s"
                    ], preserveInput);
                end%
        end%


        function this = fromEviewsString(input)
            %
            % EViews-like input
            % x = y #ma{-1} #sma{-12} #ar{-1} #sar{-12};
            %
            input = string(input);
            preserveInput = input;
            input = lower(input);
            test = erase(input, ["#", " ", "sar", "ar", "sma", "ma", "{", "}", "-", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]);
            if strlength(test)>0
                hereThrowError(preserveInput);
            end
            s = struct('ar', [], 'sar', [], 'ma', [], 'sma', []);
            tokens = regexpi(input, "#(s?ar|s?ma)\{(-[^\}]+)\}", "tokens");
            for i = 1 : numel(tokens)
                x = double(tokens{i}(2));
                if x<0
                    s.(lower(tokens{i}(1)))(end+1) = x;
                end
            end
            num = struct('ar', 0, 'sar', 0, 'ma', 0, 'sma', 0);
            func = struct('ar', "", 'sar', "", 'ma', "", 'sma', "");
            numParameters = 0;
            for n = ["ar", "sar", "ma", "sma"]
                s.(n) = reshape(sort(unique(abs(s.(n)))), 1, []);
                if isempty(s.(n))
                    func.(n) = [];
                    continue
                end
                num.(n) = numel(s.(n));
                max__ = max(s.(n));
                func.(n) = repmat("0", 1, max__);
                for j = s.(n)
                    numParameters = numParameters + 1;
                    func.(n)(j) = sprintf("p(%g)", numParameters);
                end
                func.(n) = "[1," + join(func.(n), ",") + "]";
            end
            if ~isempty(func.ar) && ~isempty(func.sar)
                ar = str2func("@(p){"+func.ar+","+func.sar+"}");
            elseif ~isempty(func.ar)
                ar = str2func("@(p)"+func.ar);
            elseif ~isempty(func.sar)
                ar = str2func("@(p)"+func.sar);
            else
                ar = [];
            end
            if ~isempty(func.ma) && ~isempty(func.sma)
                ma = str2func("@(p){"+func.ma+","+func.sma+"}");
            elseif ~isempty(func.ma)
                ma = str2func("@(p)"+func.ma);
            elseif ~isempty(func.sma)
                ma = str2func("@(p)"+func.sma);
            else
                ma = [];
            end
            this = ParamArmani(numParameters, ar, ma);

            return

                function hereThrowError(preserveInput)
                    exception.error([
                        "ParamArmani:InvalidInputString"
                        "This is not a valid input string for an ParamArmani object: %s"
                    ], preserveInput);
                end%
        end%
    end
end

