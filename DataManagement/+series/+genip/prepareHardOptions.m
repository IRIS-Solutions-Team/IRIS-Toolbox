% prepareHardOptions  Prepare hard conditioning options for Series/genip
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function hard = prepareHardOptions(transition, ~, highRange, ~, opt)

%--------------------------------------------------------------------------

numInit = transition.NumInit;
highRange = double(highRange);
highStart = highRange(1);
highEnd = highRange(end);
highFreq = DateWrapper.getFrequency(highStart);
initStart = dater.plus(highStart, -numInit);
initEnd = dater.plus(highStart, -1);

hard = struct( );
invalidFreq = string.empty(1, 0);
for g = ["Level", "Rate", "Diff"]
    hard.(g) = [ ];
    x__ = opt.("Hard_" + g);
    if isa(x__, 'NumericTimeSubscriptable') && ~isempty(x__) 
        if isfreq(x__, highFreq)
            x = getDataFromTo(x__, initStart, highEnd);
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

if numInit==0
    return
end

if isequal(opt.Initial, @auto)
    % Do nothing
else
    % Override initial condition in Hard.Level
    if isnumeric(opt.Initial)
        if isscalar(opt.Initial)
            Xi0 = repmat(opt.Initial, numInit, 1);
        else
            Xi0 = reshape(opt.Initial, [ ], 1);
            if numel(Xi0)~=numInit
                hereReportInvalidNumInitial( );
            end
        end
    elseif isa(opt.Initial, 'NumericTimeSubscriptable')
        Xi0 = getDataFromTo(opt.Initial, initStart, initEnd);
    end
    hard.Level(1:numInit) = Xi0;
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


    function hereReportInvalidNumInitial( )
        %(
        thisError = [
            "Genip:InvalidNumInitial"
            "The numeric vector assigned to Initia= has %g elements "
            "while a total of %g initial conditions is needed."
        ];
        throw(exception.Base(thisError, 'error'), numel(Xi0), numInit);
        %)
    end%
end%

