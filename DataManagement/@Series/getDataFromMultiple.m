function [outputDates, varargout] = getDataFromMultiple(dates, context, varargin)

% >=R2019b
%{
arguments
    dates
    context (1, 1) string
end

arguments (Repeating)
    varargin
end
%}
% >=R2019b


    inputSeries = varargin;

    if ~any(strcmpi(dates, ["unbalanced", "balanced"]))
        if isequal(dates, @all) || isequal(dates, Inf) || isequal(dates, [-Inf, Inf])
            dates = "unbalanced";
        else
            dates = double(dates);
        end
    end

    numSeries = numel(inputSeries);
    varargout = cell(1, numSeries);

    startDate = nan(1, numSeries);
    endDate = nan(1, numSeries);
    freq = nan(1, numSeries);
    inxNaN = false(size(inputSeries));

    if numSeries==0
        outputDates = double.empty(1, 0);
        return
    end

    for i = 1 : numSeries
        startDate(i) = double(inputSeries{i}.Start);
        endDate(i) = inputSeries{i}.EndAsNumeric;
        freq(i) = dater.getFrequency(startDate(i));
        inxNaN(i) = isnan(startDate(i));
    end

    if all(inxNaN)
        outputDates = double.empty(1, 0);
        for i = 1 : numSeries
            varargout{i} = inputSeries{i}.Data;
        end
        return
    end

    if isnumeric(dates)
        local_checkFrequencyWhenProperDates(dates, freq, context);
        outputDates = double(dates);
        for i = 1 : numSeries
            varargout{i} = getDataNoFrills(inputSeries{i}, dates);
        end
        return
    end

    local_checkFrequencyWhenImproperDates(freq, context);

    if strcmpi(dates, "unbalanced")
        from = min(startDate); 
        to = max(endDate); 
    elseif strcmpi(dates, "balanced")
        from = max(startDate); 
        to = min(endDate); 
    else
        exception.error([
            "Series"
            "Invalid date range specification"
        ]);
    end

    for i = 1 : numSeries
        varargout{i} = getDataFromTo(inputSeries{i}, from, to);
    end
    outputDates = dater.colon(from, to);

end%


function local_checkFrequencyWhenProperDates(dates, freqSeries, context)
    %(
    freqSeries = double(freqSeries);
    freqSeries(isnan(freqSeries)) = [];
    if isempty(freqSeries)
        return
    end
    if isempty(dates)
        local_checkFrequencyWhenImproperDates(freqSeries, context);
        return
    end
    freqDates = dater.getFrequency(dates(1));
    if all(freqSeries==freqDates)
        return
    end
    exception.error([
        "Series:FrequencyMismatch"
        "Date frequency of some time series is incosistent with the dates requested."
    ]);
    %)
end%


function local_checkFrequencyWhenImproperDates(freq, context)
    %(
    freq0 = freq;
    freq(isnan(freq)) = [];
    if isempty(freq) || all(freq==freq(1))
        return
    end
    freq0 = unique(string(Frequency(freq0)));
    exception.error([
        "Series:FrequencyMismatch"
        "Date frequency mismatch in input time series: %s(%s)"
    ], context, join(freq0, ", "));
    %)
end%

