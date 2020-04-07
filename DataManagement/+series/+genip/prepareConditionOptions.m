function conditions = prepareConditionOptions(highRange, options)
% prepareConditionOptions  Prepare Condition options for Series/genip
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

highRange = double(highRange);
highStart = highRange(1);
highEnd = highRange(end);
highFreq = DateWrapper.getFrequency(highStart);

conditions = struct( );
invalidFreq = cell.empty(1, 0);
for g = ["Level", "Rate", "Diff", "DiffDiff"]
    conditions.(g) = [ ];
    if isa(options.(g), 'NumericTimeSubscriptable') && ~isempty(options.(g)) 
        if isfreq(options.(g), highFreq)
            x = getDataFromTo(options.(g), highStart, highEnd);
            if ~all(isnan(x(:)))
                conditions.(g) = x;
            end
        else
            invalidFreq{end+1} = char(g);
        end
    end
end

if ~isempty(invalidFreq)
    thisError = [
        "Series:InvalidFrequencyGenip"
        "Date frequency of the time series assigned to the Indicator option %s= "
        "must match the target date frequency, which is %1. "
    ];
    throw(exception.Base(thisError, 'error'), char(highFreq), invalidFreq{:});
end

end%

