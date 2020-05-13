function Xi0 = prepareInitialCondition(transition, hard, highRange, inxInit, opt)

numInit = transition.NumInit;

if numInit==0
    Xi0 = double.empty(0, 1);
    return
end

if isequal(opt.Initial, @auto)
    if ~isempty(hard.Level)
        Xi0 = hard.Level(1:numInit);
    else
        Xi0 = nan(numInit, 1);
    end
elseif isnumeric(opt.Initial)
    if isscalar(opt.Initial)
        Xi0 = repmat(opt.Initial, numInit, 1);
    else
        Xi0 = reshape(opt.Initial, [ ], 1);
        if numel(Xi0)~=numInit
            hereReportInvalidNumInitial( );
        end
    end
elseif isa(opt.Initial, 'NumericTimeSubscriptable')
    highRange = double(highRange);
    initRange = highRange(inxInit);
    Xi0 = getDataFromTo(opt.Initial, initRange(1), initRange(end));
end

Xi0 = Xi0(end:-1:1);

return

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
