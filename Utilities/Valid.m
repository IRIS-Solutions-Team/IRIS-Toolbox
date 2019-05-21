% Valid  Utility class with static validators
%
% Backend class
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team


classdef Valid
    methods (Static)
        function flag = numericScalar(input)
           flag = isnumeric(input) && isscalar(input);
        end%

            
        function flag = roundScalar(input)
            flag = Valid.numericScalar(x) && x==round(x);
        end%


        function flag = logicalScalar(input)
            flag = isequal(input, true) | isequal(input, false);
        end%


        function flag = string(input)
            flag = ischar(input) || isa(input, 'string');
        end%


        function flag = list(input)
            flag = Valid.string(input) || iscellstr(input);
        end%


        function flag = anyString(input, varargin)
            if ~ischar(input) && ~isa(input, 'string')
                flag = false;
                return
            end
            flag = any(strcmpi(input, varargin));
        end%


        function flag = solvedModel(input)
            flag = (isa(input, 'model') || isa(input, 'Model')) ...
                   && all(beenSolved(input));
        end%
    end
end

