function outputArray = toDoubleArrayNoFrills(inputDatabank, names, dates, column, apply)
% toDoubleArrayNoFrills  Retrieve data from time series into numeric array with no checks
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

if nargin<4
    column = 1;
end

if nargin<5
    apply = [ ];
end

if isstruct(inputDatabank)
    exist = @isfield;
    retrieve = @getfield;
end

%--------------------------------------------------------------------------

if ~iscellstr(names)
    names = cellstr(names);
end

dates = double(dates);
numNames = numel(names); numDates = numel(dates);

if numNames==0
    outputArray = double.empty(numDates, 0);
    return
end

outputArray = nan(numDates, numNames);
for i = 1 : numNames
    ithName = names{i};
    if ~exist(inputDatabank, ithName)
        continue
    end
    ithField = retrieve(inputDatabank, ithName);
    if ~isa(ithField, 'NumericTimeSubscriptable')
        continue
    end
    sizeData = size(ithField);
    numColumns = prod(sizeData(2:end));
    ithValue = [ ];
    if numColumns==1
        ithValue = getDataNoFrills(ithField, dates, 1);
    elseif numColumns>1
        try
            ithValue = getDataNoFrills(ithField, dates, column);
        end
    end
    if ~isempty(ithValue) 
        if ~isempty(apply)
            ithValue = apply(ithValue);
        end
        outputArray(:, i) = ithValue;
    end
end

end%

