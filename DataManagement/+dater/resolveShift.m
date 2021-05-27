% resolveShift  Resolve time shift for time change and time growth functions
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2021 [IrisToolbox] Solutions Team

% >=R2019b
%(
function [shift, power] = resolveShift(dates, shift, opt)

arguments
    dates {mustBeReal}
    shift (1, :) {locallyValidateShift} = -1

    opt.Annualize (1, 1) logical = false
end
%)
% >=R2019b


% <=R2019a
%{
function [shift, power] = resolveShift(dates, varargin)

persistent inputParser
if isempty(inputParser)
    inputParser = extend.InputParser('DateWrapper/resolveShift');
    addRequired(inputParser, "dates", @isnumeric);
    addOptional(inputParser, "shift", -1, @locallyValidateShift);
    addParameter(inputParser, "Annualize", false, @validate.logicalScalar);
end
opt = parse(inputParser, dates, varargin{:});
shift = inputParser.Results.shift;
%}
% <=R2019a


outputFreq = [];
if opt.Annualize
    outputFreq = 1;
end

dates = reshape(double(dates), 1, [ ]);
inputFreq = dater.getFrequency(dates(1));
power = locallyResolvePower(inputFreq, outputFreq, shift);
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
        if startsWith(shift, "YoY", "ignoreCase", true)
            shift = -inputFreq;
        elseif startsWith(shift, "EoPY", "ignoreCase", true)
            shift = locallyResolveShifts(dates, 0);
        elseif startsWith(shift, "BoY", "ignoreCase", true)
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

%
% Local Validators
%

function locallyValidateShift(input)
    if validate.roundScalar(input) || startsWith(input, ["YoY", "EoPY", "BoY"], "ignoreCase", true)
        return
    end
    error("Validation:Failed", "Input value must be a negative integer or one of {""YoY"", ""EoPY"", ""BoY""}");
end%

