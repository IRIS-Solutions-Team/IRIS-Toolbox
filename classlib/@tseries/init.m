function this = init(this, dat, data)
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

dat = double(dat);
dat = dat(:);
nPer = length(dat);
nObs = size(data, 1);
dataSize = size(data);
if nObs==0 && (all(isnan(dat)) || nPer==0)
    dataSize(1) = 0;
    this.Start = NaN;
    this.Data = zeros(dataSize, prec);
    return
end

if dataSize(1)~=nPer
    utils.error('tseries:myinit', ...
        'Number of dates and number of rows of data must match.');
end

data = data(:, :);

% Remove NaN dates.
nanDates = isnan(dat);
if any(nanDates)
    data(nanDates, :) = [ ];
    dat(nanDates) = [ ];
end

% No proper date entered, return an empty tseries object.
if isempty(dat)
    this.Data = zeros([0, dataSize(2:end)]);
    this.Start = NaN;
    return
end

% Start date is the minimum date found.
start = min(dat);

% The actual stretch of the tseries range.
nPer = round(max(dat) - start + 1);
if isempty(nPer)
    nPer = 0;
end
dataSize(1) = nPer;

% Assign data points at proper dates only.
this.Data = nan(dataSize, prec);
pos = round(dat - start + 1);

% Assign user data to tseries object; note that higher dimensions will be
% preserved in `this.Data`.
this.Data(pos, :) = data;
this.Start = start;

end
