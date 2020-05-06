function hard = prepareHardOptions(transition, highRange, opt)
% prepareHardOptions  Prepare hard conditioning options for Series/genip
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

numInit = transition.Order;
highRange = double(highRange);
highStart = highRange(1);
highExtStart = DateWrapper.roundPlus(highStart, -numInit);
highEnd = highRange(end);
highFreq = DateWrapper.getFrequency(highStart);
numHighPeriods = round(highEnd - highStart + 1);

hard = struct( );
invalidFreq = string.empty(1, 0);
for g = ["Level", "Rate", "Diff"]
    hard.(g) = [ ];
    oo__ = opt.("Hard"+g);
    if isa(oo__, 'NumericTimeSubscriptable') && ~isempty(oo__) 
        if isfreq(oo__, highFreq)
            x = getDataFromTo(oo__, highExtStart, highEnd);
            if any(isfinite(x(:)))
                hard.(g) = x;
            end
        else
            invalidFreq(end+1) = "Hard." + g;
        end
    end
end


%
% Overwrite initial condition in Hard.Level with data from Initial
%
if numInit>0 && isa(opt.Initial, 'NumericTimeSubscriptable')
    if isempty(opt.Initial)
        if ~isempty(hard.Level)
            hard.Level(1:numInit) = NaN;
        end
    elseif isfreq(opt.Initial, highFreq)
        initial = getDataFromTo(opt.Initial, highExtStart, DateWrapper.roundPlus(highStart, -1));
        if ~isempty(hard.Level)
            hard.Level(1:numInit) = initial;
        elseif any(isfinite(initial))
            hard.Level = nan(numHighPeriods+numInit, 1);
            hard.Level(1:numInit) = initial;
        end
    else
        invalidFreq(end+1) = "Initial";
    end
end


if ~isempty(invalidFreq)
    hereReportInvalidFrequency( );
end

return

    function hereReportInvalidFrequency( )
        %(
        thisError = [
            "Series:InvalidFrequencyGenip"
            "Date frequency of the time series assigned to the option %s= "
            "must match the target date frequency, which is " + Frequency.toString(highFreq) + ". "
        ];
        throw(exception.Base(thisError, 'error'), invalidFreq);
        %)
    end%
end%

