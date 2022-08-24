% prepareHardOptions  Prepare hard conditioning options for Series/genip
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function hard = prepareHardOptions(transition, ~, highRange, ~, opt)

    numInit = transition.NumInit;
    highRange = double(highRange);
    highStart = highRange(1);
    highEnd = highRange(end);
    highFreq = dater.getFrequency(highStart);
    initStart = dater.plus(highStart, -numInit);
    initEnd = dater.plus(highStart, -1);
    numPeriods = dater.rangeLength(initStart, highEnd);

    % Initialize the hard conditioning series; the Level series is needed
    % nonempty
    hard = struct( );
    hard.Level = nan(numPeriods, 1);
    hard.Rate = [];
    hard.Diff = [];

    invalidFreq = string.empty(1, 0);
    for name = ["Level", "Rate", "Diff"]
        x__ = opt.("Hard" + name);
        if isa(x__, 'Series') && ~isempty(x__) 
            if isfreq(x__, highFreq)
                x = getDataFromTo(x__, initStart, highEnd);
                if any(isfinite(x(:)))
                    hard.(name) = x;
                end
            else
                invalidFreq(end+1) = "Hard" + name;
            end
        end
    end

    if ~isempty(invalidFreq)
        here_reportInvalidFrequency( );
    end

    if numInit==0
        return
    end

    % Insert initials into hard level
    if isnumeric(opt.Initials)
        Xi0 = double(opt.Initials);
        if isscalar(Xi0) && numInit>1
            Xi0 = repmat(Xi0, numInit, 1);
        end
        Xi0 = reshape(Xi0, [], 1);
        if numel(Xi0)~=numInit
            here_reportInvalidNumInitials();
        end
        hard.Level(1:numInit) = Xi0;
    elseif isa(opt.Initials, 'Series')
        Xi0 = getDataFromTo(opt.Initials, initStart, initEnd);
        hard.Level(1:numInit) = Xi0;
    end

return

    function here_reportInvalidFrequency()
        %(
        exception.error([
            "Genip"
            "Date frequency of the time series assigned to the option %s "
            "must match the target date frequency, which is " + Frequency.toString(highFreq) + ". "
        ], invalidFreq);
        %)
    end%


    function here_reportInvalidNumInitials()
        %(
        exception.error([
            "Genip"
            "The numeric vector assigned to Initials has %g elements "
            "while a total of %g initial conditions is needed."
        ], numel(Xi0), numInit);
        %)
    end%
end%

