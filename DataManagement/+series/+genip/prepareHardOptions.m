function hard = prepareHardOptions(transition, rangeHigh, opt)
% prepareHardOptions  Prepare hard conditioning options for Series/genip
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

numInit = transition.Order;
rangeHigh = double(rangeHigh);
startHigh = rangeHigh(1);
endHigh = rangeHigh(end);
freqHigh = DateWrapper.getFrequency(startHigh);
startInit = DateWrapper.roundPlus(startHigh, -numInit);

hard = struct( );
invalidFreq = string.empty(1, 0);
for g = ["Level", "Rate", "Diff"]
    hard.(g) = [ ];
    oo__ = opt.("Hard"+g);
    if isa(oo__, 'NumericTimeSubscriptable') && ~isempty(oo__) 
        if isfreq(oo__, freqHigh)
            x = getDataFromTo(oo__, startInit, endHigh);
            if any(isfinite(x(:)))
                hard.(g) = x;
            end
        else
            invalidFreq(end+1) = "Hard." + g;
        end
    end
end

if ~isempty(invalidFreq)
    hereReportInvalidFrequency( );
end

hard.Initial = nan(numInit, 1);
if numInit>0 && ~isempty(hard.Level)
    hard.Initial = hard.Level(1:numInit);
    hard.Level(1:numInit) = NaN;
end

return

    function hereReportInvalidFrequency( )
        %(
        thisError = [
            "Series:InvalidFrequencyGenip"
            "Date frequency of the time series assigned to the option %s= "
            "must match the target date frequency, which is " + Frequency.toString(freqHigh) + ". "
        ];
        throw(exception.Base(thisError, 'error'), invalidFreq);
        %)
    end%
end%

