% validate  Static utility class with validators
%
% Backend [IrisToolbox] class
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team


classdef validate
    methods (Static)
        function flag = databankType(input)
            flag = validate.anyString(input, ["struct", "Dictionary"]);
        end%


        function flag = databank(input)
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


        function flag = anyString(input, varargin)
            if ~ischar(input) && ~isstring(input)
                flag = false;
                return
            end
            if numel(varargin)==1 
                try
                    flag = matches(input, varargin{1}, "ignoreCase", true);
                catch
                    flag = any(strcmpi(input, varargin{1}));
                end
            else
                try
                    flag = any(matches(input, string(varargin), "ignoreCase", true));
                catch
                    flag = any(strcmpi(input, string(varargin)));
                end
            end
        end%


        function flag = solvedModel(input)
            flag = (isa(input, 'model') || isa(input, 'Model')) ...
                   && all(beenSolved(input));
        end%


        function flag = nestedOptions(input)
            if ~iscell(input) 
                flag = false;
                return
            end
            if ~all(cellfun(@(x) ischar(x) || isstring(x), input(1:2:end)))
                flag = false;
                return
            end
            flag = true;
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
            if ~validate.dateInput(input)
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


        function flag = dateInput(input)
            if isa(input, "DateWrapper")
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
    end


    methods (Static)
        function mustBeAnyString(x, varargin)
            if validate.anyString(x, varargin{:})
                return
            end
            error("Input value must be one of the following strings: " + sprintf("""%s""", varargin{:}) + ".");
        end%
        
        
        function mustBeAnyStringOrEmpty(x, varargin)
            if isempty(x)
                return
            end
            if validate.anyString(x, varargin{:})
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
            if isa(x, char(class))
                return
            end
            error("Input value must be of the " + string(class) + " class.");
        end%


        function mustBeText(x)
            if ischar(x) || isstring(x) || iscellstr(x) 
                return
            end
            error("Input value must be a string, char or cellstr.");
        end%
            

        function mustBeTextScalar(x)
            try
                validate.mustBeText(x);
                if isscalar(string(x))
                    return
                end
            end
            error("Input value must be a scalar text string.");
        end%
    end
end

