function outputDatabank = fromDoubleArrayNoFrills( array, ...
                                                   listOfNames, ...
                                                   start, ...
                                                   comments, ...
                                                   inxToInclude, ...
                                                   timeSeriesConstructor, ...
                                                   outputType )
% fromDoubleArrayNoFrills  Create databank from double array
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

if isequal(timeSeriesConstructor, @default)
    timeSeriesConstructor = iris.get('DefaultTimeSeriesConstructor');
end
TIME_SERIES_TEMPLATE = timeSeriesConstructor( );

if isequal(outputType, @default)
    outputType = 'struct';
end

%--------------------------------------------------------------------------

numPages = size(array, 3);
numRows = size(array, 1);

if isa(listOfNames, 'string')
    listOfNames = cellstr(listOfNames);
end

if isempty(comments)
    comments = repmat({''}, 1, numRows);
elseif isa(comments, 'string')
    comments = cellstr(comments);
end

if  numRows~=numel(listOfNames) || numRows~=numel(comments)
    THIS_ERROR = { 'Databank:InvalidSizeOfInputArguments'
                   'Invalid size of input arguments' };
    throw( exception.Base(THIS_ERROR, 'error') );
end

outputDatabank = databank.backend.ensureTypeConsistency([ ], outputType);

if isequal(inxToInclude, @all)
    inxToInclude = true(1, numRows);
end

for i = find(inxToInclude)
    ithData = array(i, :, :);
    ithData = permute(ithData, [2, 3, 1]);
    ithName = listOfNames{i};
    ithComment = comments{i};
    ithSeries = fill(TIME_SERIES_TEMPLATE, ithData, start, ithComment);
    hereStoreNewField( );
end

return


    function hereStoreNewField( )
        if strcmpi(outputType, 'struct')
            outputDatabank = setfield(outputDatabank, ithName, ithSeries);
        elseif strcmpi(outputType, 'Dictionary')
            outputDatabank = store(outputDatabank, ithName, ithSeries);
        elseif strcmpi(outputType, 'containers.Map')
            outputDatabank(ithName) = ithSeries;
        end
    end%
end%

