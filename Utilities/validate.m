% validate  Static utility class with validators
%
% Backend [IrisToolbox] class
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team


classdef validate
    methods (Static)
        function flag = matrixFormat(x)
            flag = validate.anyText(x, "namedMat", "namedMatrix", "numeric", "plain");
        end%


        function flag = databankType(input)
            flag = validate.anyText(input, ["struct", "Dictionary"]);
        end%


        function flag = databank(input, extra)
            if nargin>1 && isequal(input, extra)
                flag = true;
                return
            end
            flag = isstruct(input) || isa(input, 'Dictionary');
        end%


        function flag = numericScalar(input, lim, max)
            if ~isnumeric(input) || ~isscalar(input)
                flag = false;
                return
            end
            if nargin==1
                flag = true;
                return
            end
            if nargin>2
                lim = [lim, max];
            end
            if numel(lim)==1
                lim = [lim, Inf];
            end
            flag = input>=lim(1) && input<=lim(2);
        end%

            
        function flag = roundScalarInRange(input, min, max)
            if nargin==2 && numel(min)==2
                max = min(2);
                min = min(1);
            end
            flag = validate.numericScalar(input) && input==round(input) && input>=min && input<=max;
        end%

            
        function flag = roundScalar(input, varargin)
            flag = validate.numericScalar(input, varargin{:}) && input==round(input);
        end%


        function flag = logicalScalar(input)
            flag = isequal(input, true) | isequal(input, false);
        end%


        function flag = stringScalar(input)
            flag = ischar(input) || (isa(input, 'string') && isscalar(input));
        end%


        function flag = string(input)
            flag = ischar(input) || isa(input, 'string');
        end%


        function flag = list(input)
            flag = validate.string(input) || iscellstr(input);
        end%


        function flag = anyString(varargin)
            flag = validate.anyText(varargin{:});
        end%


        function flag = anyText(input, varargin)
            if ~validate.textScalar(input)
                flag = false;
                return
            end
            input = string(input);
            if numel(varargin)==1
                match = string(varargin{1});
            else
                match = repmat("", size(varargin));
                for i = 1 : numel(varargin)
                    match(i) = string(varargin{i});
                end
            end
            if any(lower(input)==lower(match))
                flag = true;
                return
            end
            flag = false;
        end%


        function flag = solvedModel(input)
            flag = (isa(input, 'model') || isa(input, 'Model')) ...
                   && all(beenSolved(input));
        end%


        function flag = nestedOptions(input)
            %(
            if ~iscell(input) 
                flag = false;
                return
            end
            if ~all(cellfun(@(x) ischar(x) || isstring(x), input(1:2:end)))
                flag = false;
                return
            end
            flag = true;
            %)
        end%


        function mustBeDateFormat(x)
            %(
            %)
        end%


        function mustBeMatrixFormat(x)
            if validate.matrixFormat(x)
                return
            end
            error("Input value must be one of valid matrix formats ""numeric"" or ""namedMatrix");
        end%


        function mustBeNestedOptions(x)
            %(
            if validate.nestedOptions(x)
                return 
            end
            error("Input value must be a cell array with name-value pairs for nested options or settings.");
            %)
        end%


        function flag = frequency(input)
            if ~isnumeric(input)
                flag = false;
                return
            end
            try
                Frequency.fromNumeric(input);
                flag = true;
            catch
                flag = false;
            end
        end%


        function flag = properDates(input)
            flag = validate.properDate(input);
        end%


        function flag = properDate(input)
            if ~isnumeric(input)
                flag = false;
                return
            end
            input = reshape(double(input), 1, [ ]);
            if any(~isfinite(input))
                flag = false;
                return
            end
            freq = dater.getFrequency(input);
            if any(~isfinite(input))
                flag = false;
                return
            end
            flag = true;
        end%


        function flag = properRange(input)
            if ~validate.range(input)
                flag = false;
                return
            end
            if isequal(input, @all) || isempty(input) || any(isinf(input))
                flag = false;
                return
            end
            flag = true;
        end%


        function flag = rangeInput(input)
            flag = validate.range(input);
        end%


        function flag = range(input)
            if isequal(input, Inf) || isequal(input, @all)
                flag = true;
                return
            end
            if ~validate.date(input)
                flag = false;
                return
            end
            if numel(input)==1
                flag = true;
                return
            end
            if numel(input)==2
                if (isinf(input(1)) || isinf(input(2)))
                    flag = true;
                    return
                elseif all(freqcmp(input))
                    flag = true;
                    return
                else
                    flag = false;
                    return
                end
            end
            if ~all(freqcmp(input))
                flag = false;
                return
            end
            if ~all(round(diff(input))==1)
                flag = false;
                return
            end
            flag = true;
        end%


        function flag = date(input)
            if isa(input, 'DateWrapper')
                flag = true;
                return
            end
            if isnumeric(input)
                try
                    dater.getFrequency(input);
                    flag = true;
                catch
                    flag = false;
                end
                return
            end
            if isequal(input, @all)
                flag = true;
                return
            end
            flag = false;
        end%


        function flag = text(input)
            if isstring(input) || ischar(input) || iscellstr(input)
                flag = true;
                return
            end
            flag = false;
        end%


        function flag = func(input)
            if isa(input, 'function_handle')
                flag = true;
                return
            end
            flag = false;
        end%
    end


    methods (Static)
        function mustBeAnyString(x, varargin)
            if validate.anyText(x, varargin{:})
                return
            end
            error("Input value must be one of the following strings: " + sprintf(" ""%s""", varargin{:}) + ".");
        end%
        
        
        function mustBeAnyStringOrEmpty(x, varargin)
            if isempty(x)
                return
            end
            if validate.anyText(x, varargin{:})
                return
            end
            error("Input value must be one of the following strings: " + sprintf("""%s""", varargin{:}) + ".");
        end%


        function mustBeScalarOrEmpty(x)
            if isscalar(x) || isempty(x)
                return
            end
            error("Input value must be empty or a scalar.");
        end%


        function mustBeInRange(x, lower, upper)
            if isempty(x)
                return
            end
            if all(x(:)>=lower) && all(x(:)<=upper)
                return
            end
            error("Input value must be between " + string(lower) + " and " + string(upper) + ".");
        end%


        function mustBeA(x, class)
            class = string(class);
            if any(arrayfun(@(c) isa(x, c), class))
                return
            end
            error("Input value must be the " + join(class, " or ") + " class.");
        end%


        function mustBeText(x)
            if validate.text(x)
                return
            end
            error("Input value must be a string, char or cellstr.");
        end%


        function flag = textScalar(x)
            %(
            if validate.text(x) && numel(string(x))==1
                flag = true;
                return
            end
            flag = false;
            %)
        end%


        function mustBeTextScalar(x)
            %(
            if validate.textScalar(x)
                return
            end
            error("Input value must be a scalar text string.");
            %)
        end%


        function mustBeDate(x)
            if isequal(validate.date(x), true)
                return
            end
            error("Input value must be a date or an array of dates.");
        end%


        function mustBeRange(x)
            if isequal(validate.range(x), true)
                return
            end
            error("Input value must be a date range.");
        end%


        function mustBeDatabank(x, varargin)
            if isequal(validate.databank(x, varargin{:}), true)
                return
            end
            error("Input value must be a databank (struct or Dictionary).");
        end%


        function mustBeDatabankOrEmpty(x, varargin)
            if isempty(x)
                return
            end
            if isequal(validate.databank(x, varargin{:}), true)
                return
            end
            error("Input value must be a databank (struct or Dictionary).");
        end%


        function mustBeProperRange(x)
            if isequal(validate.properRange(x), true)
                return
            end
            error("Input value must be a proper date range.");
        end%


        function mustBeFunc(x)
            if isequal(validate.func(x), true)
                return
            end
            error("Input value must be a function handle.");
        end%


        function mustBeSolveModel(x)
            if isa(x, 'Model') && all(beenSolved(x))
                return
            end
            error("Input value must be a solved Model object.")
        end%


        function mustBeOutputType(x)
            if isequal(x, @auto)
                return
            end
            if validate.databankType(x)
                return
            end
            error("Input value must be @auto, a struct, or a Dictionary object.");
        end%
        
        function mustBeLogicalOrSuboptions(x)
            if islogical(x) && isscalar(x)
                return
            end
            if iscell(x) && isrow(x) && all(cellfun(@(n) ischar(n) || isstring(n), x(1:2:end)))
                return
            end
            error("Input value must be true, false, or a cell array of suboptions.");
        end%
    end
end

