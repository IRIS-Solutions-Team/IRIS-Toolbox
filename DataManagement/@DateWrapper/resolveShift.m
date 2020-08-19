% resolveShift  Resolve time shift for time change and time growth functions
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function [shift, power] = resolveShift(dates, varargin)

%( Input parser
persistent pp
if isempty(pp)
    pp = extend.InputParser('@DateWrapper/resolveShift');
    addRequired(pp, 'dates', @isnumeric);
    addOptional(pp, 'shift', -1, @(x) validate.roundScalar(x) || validate.anyString(x, ["YoY", "EoPY", "BoY"]));
    addParameter(pp, 'Annualize', false, @validate.logicalScalar);

    % Legacy option
    addParameter(pp, 'OutputFreq', [ ], @(x) isempty(x) || isa(Frequency(x), 'Frequency'));
end
%)
opt = parse(pp, dates, varargin{:});
shift = pp.Results.shift;
if opt.Annualize
    opt.OutputFreq = 1;
end

%--------------------------------------------------------------------------

dates = reshape(double(dates), 1, [ ]);
inputFreq = dater.getFrequency(dates(1));
power = locallyResolvePower(inputFreq, opt.OutputFreq, shift);
shift = locallyResolveShift(dates, inputFreq, shift);

end%

%
% Local Functions
%

function shift = locallyResolveShift(dates, inputFreq, shift)
    %(
    if isnumeric(shift)
        return
    else
        if inputFreq==0 
            throw(exception.Base([
                "NumericTimeSubscriptable:IncompatibleInputs"
                "Time shift cannot be specified as ""YoY"", ""BoY"", or ""EoPY"" "
                "for time series of INTEGER date frequency. "
            ], "error"));
        end
        if matches(shift, "YoY", "ignoreCase", true)
            shift = -inputFreq;
        elseif matches(shift, "EoPY", "ignoreCase", true)
            shift = locallyResolveShifts(dates, 0);
        elseif matches(shift, "BoY", "ignoreCase", true)
            shift = locallyResolveShifts(dates, -1);
        end
    end
    %)
end%


function shift = locallyResolveShifts(dates, offset)
    %(
    [~, periods] = dat2ypf(dates);
    shift = -( reshape(periods, 1, [ ]) + offset );
    %)
end%


function power = locallyResolvePower(inputFreq, outputFreq, shift)
    %(
    power = 1;
    if ~isempty(outputFreq)
        if ~isnumeric(shift) || ~isscalar(shift)
            throw(exception.Base([ 
                "NumericTimeSubscriptable:IncompatibleInputs"
                "Annualized changes or option OutputFreq= cannot be combined "
                "with the time shift specified as ""BoY"" or ""EoPY"". "
            ], "error"));
        end
        power = double(inputFreq) / double(outputFreq) / abs(shift);
    end
    %)
end%

