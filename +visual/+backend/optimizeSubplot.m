function [numRows, numColumns] = optimizeSubplot(totalCount, varargin)
% optimizeSubplot  Choose number of rows and columns for subplot given the total count of graphs to be plotted.
%
% __Syntax__
%
%     [NumRows, NumColumns] = grfun.optimizeSubplot(TotalCount, ...)
%
%
% __Input Arguments__
%
% * `TotalCount` [ numeric ] - Total number of graphs to be plotted in one
% figure window.
%
%
% __Output Arguments__
%
% * `NumRows` [ numeric ] - Number of rows.
%
% * `NumColumns` [ numeric ] - Number of columns.
%
%
% __Options__
%
% * `'Orientation='` [ *`'landscape'`* | `'portrait'` ] - Orientation of
% the figure window.
%
%
% __Description__
%
%
% __Examples__
%
%     totalCount = 15;
%     [numRows, numColumns] = grfun.optimize(totalCount);
%     for i = 1 : totalCount
%         subplot(numRows, numColumns, i);
%         plot(rand(10));
%     end
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team.

persistent INPUT_PARSER
if isempty(INPUT_PARSER)
    INPUT_PARSER = extend.InputParser('grfun/optimizeSubplot');
    INPUT_PARSER.addRequired('TotalCount', @(x) isnumeric(x) && numel(x)==1 && x==round(x));
    INPUT_PARSER.addOptional('Orientation', 'landscape', @(x) any(strcmpi(x, {'landscape', 'portrait'})));
end

INPUT_PARSER.parse(totalCount, varargin{:});

%--------------------------------------------------------------------------

s = ceil(sqrt(totalCount));
if s*(s-1)>=totalCount
    if strcmpi(INPUT_PARSER.Results.Orientation, 'landscape')
        numRows = s-1;
        numColumns = s;
    else
        numRows = s;
        numColumns = s-1;
    end
else
    numRows = s;
    numColumns = s;
end

end
