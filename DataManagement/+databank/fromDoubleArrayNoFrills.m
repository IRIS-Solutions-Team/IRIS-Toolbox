function outputDatabank = fromDoubleArrayNoFrills(array, listOfNames, start, comments, inxToInclude, timeSeriesConstructor)
% fromDoubleArrayNoFrills  Create databank from double array
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

try
    timeSeriesConstructor;
catch
    timeSeriesConstructor = iris.get('DefaultTimeSeriesConstructor');
end
TIME_SERIES = timeSeriesConstructor( );

%--------------------------------------------------------------------------

numOfDataSets = size(array, 3);
numOfRows = size(array, 1);

if isa(listOfNames, 'string')
    listOfNames = cellstr(listOfNames);
end

if isempty(comments)
    comments = repmat({''}, 1, numOfRows);
elseif isa(comments, 'string')
    comments = cellstr(comments);
end

if  numOfRows~=numel(listOfNames) || numOfRows~=numel(comments)
    THIS_ERROR = { 'Databank:InvalidSizeOfInputArguments'
                   'Invalid size of input arguments' };
    throw( exception.Base(THIS_ERROR, 'error') );
end

outputDatabank = struct( );
try
    inxToInclude;
catch
    inxToInclude = true(1, numOfRows);
end
for i = find(inxToInclude)
    ithData = array(i, :, :);
    ithData = permute(ithData, [2, 3, 1]);
    ithName = listOfNames{i};
    ithComment = comments{i};
    outputDatabank.(ithName) = fill(TIME_SERIES, ithData, start, ithComment);
end

end%

