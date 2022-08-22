% prctile  Percentiles from numeric data
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

function y = prctile(x, percents, varargin)

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser();
    inputParser.addRequired('inputData', @isnumeric);
    inputParser.addRequired('percents', @(x) isnumeric(x) && all(x>=0) && all(x<=100));
    inputParser.addOptional('dim', 1, @(x) isnumeric(x) && isscalar(x) && x==round(x) && x>=1);
end
inputParser.parse(x, percents, varargin{:});
dim = inputParser.Results.dim;

%--------------------------------------------------------------------------

percents = percents(:).';
numPercents = length(percents);

% Put the requested dimension first, and unfold x(:, :)
x0 = x;
[x, redimStruct] = series.redim(x, dim);

[numRows, numColumns] = size(x);
y = nan(numPercents, numColumns);

% Remove all rows that only contain NaNs.
indexAllNaNRows = all(isnan(x), 2);
x(indexAllNaNRows, :) = [ ];
        
if ~isempty(x)
    x = sort(x, 1);
    % First, do all columns that do not contain any NaNs at once.
    indexNaNColumns = any(isnan(x), 1);
    if any(~indexNaNColumns)
        y(:, ~indexNaNColumns) = prctilesFromSample(x(:, ~indexNaNColumns), percents);
    end
    % Then, cycle over columns with NaNs individually.
    for i = find(indexNaNColumns)
        ithX = x(:, i);
        ithX(isnan(ithX)) = [ ];
        if isempty(ithX)
            continue
        end
        y(:, i) = prctilesFromSample(ithX, percents);
    end
end

y = series.redim(y, dim, redimStruct);

return


    function p = prctilesFromSample(x, percents)
        % Repeat the smallest and largest observations to generate
        % the 0-th and 100-th percentiles.
        n = size(x, 1);
        grid = [0, 100*(0.5:n - 0.5)./n, 100];
        xx = x([1, 1:end, end], :);
        p = interp1(grid, xx, percents, 'linear');
    end 
end
