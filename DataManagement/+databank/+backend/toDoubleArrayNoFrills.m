function outputArray = toDoubleArrayNoFrills(inputDb, names, dates, column, apply)
% toDoubleArrayNoFrills  Retrieve data from time series into numeric array with no checks
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

if nargin<4
    column = 1;
end

if nargin<5
    apply = [ ];
end

%--------------------------------------------------------------------------

names = cellstr(names);
dates = double(dates);
numNames = numel(names); numDates = numel(dates);

if numNames==0
    outputArray = double.empty(numDates, 0);
    return
end

outputArray = nan(numDates, numNames);
for i = 1 : numNames
    name__ = names{i};
    if ~isfield(inputDb, name__)
        continue
    end
    if isstruct(inputDb)
        field__ = inputDb.(name__);
    else
        field__ = retrieve(inputDb, name__);
    end
    if ~isa(field__, 'NumericTimeSubscriptable')
        continue
    end
    sizeData = size(field__);
    numColumns = prod(sizeData(2:end));
    value__ = [ ];
    if numColumns==1
        value__ = getDataNoFrills(field__, dates, 1);
    elseif numColumns>1
        try
            value__ = getDataNoFrills(field__, dates, column);
        end
    end
    if ~isempty(value__) 
        if ~isempty(apply)
            value__ = apply(value__);
        end
        outputArray(:, i) = value__;
    end
end

end%

