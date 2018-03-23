function x = diff(x, varargin)
% diff  Implement diff for numeric data
%
% Backend IRIS function
% No help provided

% -Copyright (c) 2007-2018 IRIS Solutions Team
% -IRIS Macroeconomic Modeling Toolbox

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('numeric.diff');
    INPUT_PARSER.addRequired('InputData', @isnumeric);
    INPUT_PARSER.addOptional('Shifts', -1, @(x) isnumeric(x) && all(x==round(x)));
end
INPUT_PARSER.parse(x, varargin{:});
shifts = INPUT_PARSER.Results.Shifts;

if isempty(shifts)
    x = numeric.empty(x, 2);
    return
end

%--------------------------------------------------------------------------

numShifts = numel(shifts);
x = repmat(x, 1, numShifts) - numeric.shift(x, shifts);

end
