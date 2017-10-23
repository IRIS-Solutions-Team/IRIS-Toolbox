function this = init(this, dates, data)
% init  Create start date and data for new tseries object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isa(data, 'single')
    prec = 'single';
else
    prec = 'double';
end

dates = dates(:);
numDates = length(dates);
numObservations = size(data, 1);
sizeData = size(data);
if numObservations==0 && (all(isnan(dates)) || numDates==0)
    sizeData(1) = 0;
    this.Start = DateWrapper(NaN);
    this.Data = zeros(sizeData, prec);
    return
end

assert( ...
    sizeData(1)==numDates, ...
    'tseries:init', ...
    'The number of dates and the number of rows of data must match.' ...
);

data = data(:, :);

% Remove NaN dates.
ixNanDates = isnan(dates);
if any(ixNanDates)
    data(ixNanDates, :) = [ ];
    dates(ixNanDates) = [ ];
end

% No proper date entered, return an empty tseries object.
if isempty(dates)
    sizeData(1) = 0;
    this.Start = DateWrapper(NaN);
    this.Data = zeros(sizeData);
    return
end

% Start date is the minimum date found.
startDate = min(dates);
endDate = max(dates);

% The actual stretch of the tseries range.
numDates = rnglen(startDate, endDate);
if isempty(numDates)
    numDates = 0;
end
sizeData(1) = numDates;

% Assign data points at proper dates only.
this.Data = nan(sizeData, prec);
posData = rnglen(startDate, dates);

% Assign user data to tseries object; note that higher dimensions will be
% preserved in `this.Data`.
this.Data(posData, :) = data;
this.Start = startDate;

end
