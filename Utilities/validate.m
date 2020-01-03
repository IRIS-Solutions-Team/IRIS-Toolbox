% validate  Static utility class with validators
%
% Backend class
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team


classdef validate
    methods (Static)
        function flag = databankType(input)
            flag = validate.anyString(input, 'struct', 'Dictionary');
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
            if ~validate.string(input)
                flag = false;
                return
            end
            if numel(varargin)==1 && isa(varargin{1}, 'string')
                flag = any(strcmpi(input, varargin{1}));
            else
                flag = any(strcmpi(input, varargin));
            end
        end%


        function flag = solvedModel(input)
            flag = (isa(input, 'model') || isa(input, 'Model')) ...
                   && all(beenSolved(input));
        end%
    end
end

