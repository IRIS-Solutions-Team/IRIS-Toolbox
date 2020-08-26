function outputDb = fromDoubleArrayNoFrills( ...
    array, ...
    names, ...
    startDate, ...
    comments, ...
    inxToInclude, ...
    timeSeriesConstructor, ...
    outputType, ...
    addToDatabank ...
)
% fromDoubleArrayNoFrills  Create databank from double array
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

if nargin<8
    addToDatabank = false;
end

if isequal(timeSeriesConstructor, @default)
    timeSeriesConstructor = iris.get('DefaultTimeSeriesConstructor');
end
TIME_SERIES_TEMPLATE = timeSeriesConstructor( );

%--------------------------------------------------------------------------

numRows = size(array, 1);
names = reshape(string(names), 1, [ ]);

if isempty(comments)
    comments = repmat({''}, 1, numRows);
elseif isa(comments, 'string')
    comments = reshape(cellstr(comments), 1, [ ]);
end

hereCheckDimensions( );

if ~isa(startDate, 'DateWrapper')
    startDate = DateWrapper(startDate);
end

outputDb = databank.backend.ensureTypeConsistency(addToDatabank, outputType);

if isequal(inxToInclude, @all)
    inxToInclude = true(1, numRows);
end

for i = find(inxToInclude)
    data__ = array(i, :, :);
    data__ = permute(data__, [2, 3, 1]);
    series__ = fill(TIME_SERIES_TEMPLATE, data__, startDate, comments{i});
    outputDb.(names(i)) = series__;
end

return

    function hereCheckDimensions( )
        %(
        if numRows==numel(names) && numRows==numel(comments)
            return
        end
        thisError = [ 
            "Databank:InvalidSizeOfInputArguments"
            "Invalid dimensions of some of the input arguments {array, names, comments}"
        ];
        throw(exception.Base(thisError, 'error'));
        %)
    end%
end%

