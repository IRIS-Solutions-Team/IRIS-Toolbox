function this = seasonDummy(range, dummyPeriods, varargin)

    range = double(range);
    range = dater.colon(range(1), range(end));
    [~, periods] = dater.getYearPeriodFrequency(range);
    periods = reshape(periods, [ ], 1);
    dummyPeriods = reshape(dummyPeriods, [ ], 1);
    values = double(ismember(periods, dummyPeriods));
    this = Series(range, values, varargin{:}, "--skip");

    if all(values(:)==0)
        exception.warning([
            "Series:SeasonalDummiesAllZeros"
            "The seasonal dummy time series contains all zeros."
        ]);
    end

end%

