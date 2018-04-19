function rangeFrequencies = rngfreq(range)
% rngfreq  Determine date frequencies of input ranges or cell array of ranges
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2018 IRIS Solutions Team

if iscell(range)
    rangeFrequencies = nan(size(range));
    for i = 1 : numel(range)
        rangeFrequencies(i) = rngfreq(range{i});
    end
    return
end

%--------------------------------------------------------------------------

if any(isnan(range))
    rangeFrequencies = NaN;
    return
end

if all(isinf(range))
    rangeFrequencies = Inf;
    return
end

range = range(~isinf(range));

freq = DateWrapper.getFrequencyFromNumeric(range);
if all(freq==freq(1))
    rangeFrequencies = freq(1);
else
    rangeFrequencies = NaN;
end

end
