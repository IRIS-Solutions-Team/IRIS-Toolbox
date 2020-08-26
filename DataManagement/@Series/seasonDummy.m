function this = seasonDummy(dates, dummyPeriods, varargin);

[~, periods] = dat2ypf(dates);
periods = reshape(periods, [ ], 1);
dummyPeriods = reshape(dummyPeriods, [ ], 1);
values = double(ismember(periods, dummyPeriods));
this = Series(dates, values , varargin{:}, "--skip");

if all(values(:)==0)
    exception.warning([
        "Series:SeasonalDummiesAllZeros"
        "The seasonal dummy time series contains all zeros."
    ]);
end

end%

