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
            if numel(varargin)==1 && isa(varargin{1}, 'string')
                flag = matches(input, varargin{1}, "ignoreCase", true);
            else
                flag = matches(input, string(varargin), "ignoreCase", true);
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
    end


    methods (Static)
        function mustBeAnyString(x, varargin)
            if ~validate.anyString(x, varargin{:})
                error("Must be one of the following strings: " + sprintf("""%s""", varargin{:}));
            end
        end%
    end
end

