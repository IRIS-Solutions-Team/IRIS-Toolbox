function [outputDates, varargout] = getDataFromAll(dates, varargin)

numberOfSeries = numel(varargin);
varargout = cell(1, numberOfSeries);

startDate = cell(size(varargin));
endDate = cell(size(varargin));
ixNad = false(size(varargin));
for i = 1 : numberOfSeries
    startDate{i} = varargin{i}.Start;
    endDate{i} = varargin{i}.End;
    ixNad(i) = isnad(startDate{i});
end

if all(ixNad)
    outputDates = Date.NaD;
    for i = 1 : numberOfSeries
        varargout{i} = varargin{i}.Data;
    end
    return
end

assert( ...
    validate(startDate{~ixNad}), ...
    'TimeSeries:getDataFromAll', ...
    'TimeSeries inputs must have the same date frequency.' ...
);

if isa(dates, 'Date')
    outputDates = dates;
    for i = 1 : numberOfSeries
        varargout{i} = getDataNoFrills(varargin{i}, dates);
    end
    return
end

if strcmp(dates, 'longRange') || isequal(dates, Inf)
    from = min(startDate{:}); % Very first date
    to = max(endDate{:}); % Very last date
elseif strcmp(dates, 'shortRange')
    from = max(startDate{:}); % First date available for all
    to = min(endDate{:}); % First data available for all
else
    error( ...
        'databank:getDataFromAll', ...
        'Invalid date specification.' ...
    );
end

for i = 1 : numberOfSeries
    varargout{i} = getDataFromRange(varargin{i}, from, to);
end
outputDates = from : to;

end
