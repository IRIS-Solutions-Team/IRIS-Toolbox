function value = validateTimeVaryingInput(context, range, input, canHaveMissing)

range = double(range);
startDate = range(1);
endDate = range(end);

numPeriods = round(range(end) - range(1) + 1);
if isnumeric(input) 
    if isscalar(input) || numel(input)==numPeriods
        value = reshape(input, [ ], 1);
        return
    else
        hereThrowDimension( );
    end
end

freq = Dater.getFrequency(range(1));
if isa(input, 'Series')
    if isfreq(input, freq)
        value = getDataFromTo(input, startDate, endDate);
        if ~canHaveMissing && any(~isfinite(value(:)))
            hereThrowMissing( );
        end
    else
        hereThrowFrequency( );
    end
end

return

    function hereThrowDimension( )
        thisError = [
            "Genip:InvalidDimensions"
            "Dimensions of the value assigned to this option are inconsistent "
            "with the number of periods: %s "
        ];
        throw(exception.Base(thisErrorm, 'error'), context);
    end%


    function hereThrowMissing( )
        thisError = [ 
            "Genip:InvalidFrequency"
            "Time series assigned to this option contains NaNs or Infs "
            "within the interpolation range: %s "
        ];
        throw(exception.Base(thisError, 'error'), context);
    end%


    function hereThrowFrequency( )
        thisError = [ 
            "Genip:InvalidFrequency"
            "Date frequency of the time series assigned to this option "
            "is inconsistent with the frequency of the interpolation range: %s "
        ];
        throw(exception.Base(thisErrorm, 'error'), context);
    end%
end%
