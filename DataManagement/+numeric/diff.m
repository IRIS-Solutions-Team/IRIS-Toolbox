function x = diff(x, varargin)
% diff  Implement diff for numeric data
%
% Backend IRIS function
% No help provided

% -Copyright (c) 2007-2020 IRIS Solutions Team
% -IRIS Macroeconomic Modeling Toolbox

persistent parser
if isempty(parser)
    parser = extend.InputParser('numeric.diff');
    parser.addRequired('InputData', @isnumeric);
    parser.addOptional('Shifts', -1, @(x) isnumeric(x) && all(x==round(x)));
end
parser.parse(x, varargin{:});
shifts = parser.Results.Shifts;

if isempty(shifts)
    x = numeric.empty(x, 2);
    return
end

%--------------------------------------------------------------------------

numShifts = numel(shifts);
x = repmat(x, 1, numShifts) - numeric.shift(x, shifts);

end%

