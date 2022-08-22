% hpdi  Highest probability density interval
%

function int = hpdi(x, coverage, varargin)

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser();
    inputParser.addRequired('InputData', @isnumeric);
    inputParser.addRequired('Coverage', @(x) isnumeric(x) && isscalar(x) && x>=0 && x<=100);
    inputParser.addOptional('Dim', 1, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>=1);
end
inputParser.parse(x, coverage, varargin{:});
dim = inputParser.Results.Dim;

%--------------------------------------------------------------------------

% Put requested dimenstion first, unfold array into 2D
[x, redimStruct] = series.redim(x, dim);

% Proceed columwise
[numRows, numColumns] = size(x);
numToExclude = round((1-coverage/100)*numRows);
int = nan(2, numColumns);
for i = 1 : numColumns
    ithX = x(:, i);
    ithX(isnan(ithX)) = [ ];
    if isempty(ithX)
        continue
    end
    ithX = sort(ithX);
    distance = ithX((end-numToExclude):end) - ithX(1:(numToExclude+1));
    [minDistance, pos] = min(distance);
    pos = pos(1);
    int(1, i) = ithX(pos);
    int(2, i) = ithX(pos) + minDistance;
end

% Rearrange results back to conform with input array dimensions
int = series.redim(int, dim, redimStruct);

end%

