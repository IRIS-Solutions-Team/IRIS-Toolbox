function this = apply(func, this, dates, varargin)
% apply  Apply function to time series period by period
%{
%}

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

%--------------------------------------------------------------------------

if isempty(dates)
    return
end

[minSh, maxSh] = hereGetShifts( );
dates = reshape(double(dates), 1, [ ]);
minDate = min(dates);
maxDate = max(dates);
extendedStart = DateWrapper.roundPlus(minDate, minSh);
extendedEnd = DateWrapper.roundPlus(maxDate, maxSh);

data = getDataFromTo(this, extendedStart, extendedEnd);
sizeData = size(data);

inxSeries = cellfun(@(x) isa(x, 'NumericTimeSubscriptable'), varargin);
varargin(inxSeries) = cellfun( @(x) getDataFromTo(x, extendedStart, extendedEnd), ...
                               varargin(inxSeries), 'UniformOutput', false );

higherRef = repmat({':'}, 1, ndims(data)-1);
posDates = round(dates - extendedStart + 1);
for t = posDates
    data(t, higherRef{:}) = func(data, t, varargin{:});
end

this = setData(this, dates, data(posDates, higherRef{:}));

return

    function [minSh, maxSh] = hereGetShifts( )
        match = regexp(func2str(func), 't[\+\-]\d+', 'match');
        sh = cellfun(@(x) sscanf(x(2:end), '%g'), match);
        minSh = min([sh, 0]);
        maxSh = max([sh, 0]);
    end%
end%
