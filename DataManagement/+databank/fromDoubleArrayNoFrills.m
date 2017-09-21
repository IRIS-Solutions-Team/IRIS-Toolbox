function databank = fromDoubleArrayNoFrills(array, listOfNames, start, comments)

TIME_SERIES_CONSTRUCTOR = getappdata(0, 'IRIS_TimeSeriesConstructor');
TIME_SERIES = TIME_SERIES_CONSTRUCTOR( );

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

assert( ...
    numOfRows==numel(listOfNames) && numOfRows==numel(comments), ...
    'databank:fromDoubleArrayNoFrills', ...
    'Invalid size of input arguments'
);

for i = 1 : numOfRows
    ithData = array(i, :, :);
    ithData = permute(ithData, [2, 3, 1]);
    ithName = listOfNames{i};
    ithComment = comments{i};
    d.(ithName) = fill(TIME_SERIES, ithData, start, ithComment);
end

end

