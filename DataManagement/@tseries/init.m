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
numberOfDates = length(dates);
nObs = size(data, 1);
sizeOfData = size(data);
if nObs==0 && (all(isnan(dates)) || numberOfDates==0)
    sizeOfData(1) = 0;
    this.Start = NaN;
    this.Data = zeros(sizeOfData, prec);
    return
end

if sizeOfData(1)~=numberOfDates
    utils.error('tseries:myinit', ...
        'Number of dates and number of rows of data must match.');
end

data = data(:, :);

% Remove NaN dates.
ixNanDates = isnan(dates);
if any(ixNanDates)
    data(ixNanDates, :) = [ ];
    dates(ixNanDates) = [ ];
end

% No proper date entered, return an empty tseries object.
if isempty(dates)
    this.Data = zeros([0, sizeOfData(2:end)]);
    this.Start = NaN;
    return
end

% Start date is the minimum date found.
start = min(dates);

% The actual stretch of the tseries range.
numberOfDates = round(max(dates) - start + 1);
if isempty(numberOfDates)
    numberOfDates = 0;
end
sizeOfData(1) = numberOfDates;

% Assign data points at proper dates only.
this.Data = nan(sizeOfData, prec);
pos = round(dates - start + 1);

% Assign user data to tseries object; note that higher dimensions will be
% preserved in `this.Data`.
this.Data(pos, :) = data;
this.Start = start;

end
