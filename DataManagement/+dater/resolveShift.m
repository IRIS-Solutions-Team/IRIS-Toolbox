% resolveShift  Resolve time shift for time change and time growth functions
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

% >=R2019b
%{
function [shift, power] = resolveShift(dates, shift, opt)

arguments
    dates {mustBeReal}
    shift (1, :) {local_validateShift}

    opt.Annualize (1, 1) logical = false
end
%}
% >=R2019b


% <=R2019a
%(
function [shift, power] = resolveShift(dates, shift, varargin)

persistent ip
if isempty(ip)
    ip = inputParser();
    addParameter(ip, "Annualize", false);
end
parse(ip, varargin{:});
opt = ip.Results;
%)
% <=R2019a


outputFreq = [];
if opt.Annualize
    outputFreq = 1;
end

dates = reshape(double(dates), 1, [ ]);
inputFreq = dater.getFrequency(dates(1));
power = local_resolvePower(inputFreq, outputFreq, shift);
shift = local_resolveShift(dates, inputFreq, shift);

end%

%
% Local functions
%

function shift = local_resolveShift(dates, inputFreq, shift)
    %(
    if isnumeric(shift)
        return
    else
        if inputFreq==0 
            throw(exception.Base([
                "Series:IncompatibleInputs"
                "Time shift cannot be specified as ""YoY"", ""BoY"", or ""EoPY"" "
                "for time series of INTEGER date frequency. "
            ], "error"));
        end
        if startsWith(shift, "yoy", "ignoreCase", true)
            shift = -inputFreq;
        elseif startsWith(shift, "eopy", "ignoreCase", true)
            shift = local_resolveShifts(dates, 0);
        elseif startsWith(shift, "boy", "ignoreCase", true)
            shift = local_resolveShifts(dates, -1);
        elseif startsWith(shift, "tty", "ignoreCase", true)
            [~, periods] = dat2ypf(dates);
            shift = repmat(-1, size(periods));
            shift(periods==1) = 0;
        end
    end
    %)
end%


function shift = local_resolveShifts(dates, offset)
    %(
    [~, periods] = dat2ypf(dates);
    shift = -(reshape(periods, 1, [ ]) + offset);
    %)
end%


function power = local_resolvePower(inputFreq, outputFreq, shift)
    %(
    power = 1;
    if ~isempty(outputFreq)
        if ~isnumeric(shift) || ~isscalar(shift)
            throw(exception.Base([ 
                "Series:IncompatibleInputs"
                "Annualized changes or option OutputFreq= cannot be combined "
                "with the time shift specified as ""BoY"" or ""EoPY"". "
            ], "error"));
        end
        power = double(inputFreq) / double(outputFreq) / abs(shift);
    end
    %)
end%

%
% Local validators
%

function local_validateShift(input)
    %(
    if validate.roundScalar(input) || ((ischar(input) || isstring(input)) && startsWith(input, ["yoy", "eopy", "boy", "tty"], "ignoreCase", true))
        return
    end
    error("Input value must be an integer or one of {""yoy"", ""eopy"", ""boy"", ""tty""}");
    %)
end%

