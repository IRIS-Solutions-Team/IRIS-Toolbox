% fromArrayNoFrills  Create databank from double array
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function outputDb = fromArrayNoFrills( ...
    array, ...
    names, ...
    startDate, ...
    comments, ...
    inxToInclude, ...
    outputType, ...
    targetDb ...
)

try, targetDb;
    catch, targetDb = false;
end

TIME_SERIES_TEMPLATE = Series();

%--------------------------------------------------------------------------

numRows = size(array, 1);
numDims = ndims(array);
names = textual.stringify(names);

if isempty(comments)
    comments = repmat({''}, 1, numRows);
elseif isstring(comments)
    comments = cellstr(comments);
end

here_checkDimensions();

startDate = double(startDate);

outputDb = databank.backend.ensureTypeConsistency(targetDb, outputType);

if isequal(inxToInclude, @all)
    inxToInclude = true(1, numRows);
end

for i = find(inxToInclude)
    data__ = permute(array(i, :, :), [2, 3:numDims, 1]);
    series__ = fill(TIME_SERIES_TEMPLATE, data__, startDate, comments{i});
    outputDb.(names(i)) = series__;
end

return

    function here_checkDimensions( )
        %(
        if numRows==numel(names) && numRows==numel(comments)
            return
        end
        exception.error([
            "Databank"
            "Invalid dimensions of some of the input arguments {array, names, comments}. "
        ]);
        %)
    end%
end%

