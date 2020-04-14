function indicator = prepareIndicatorOptions(model, highRange, options)
% prepareIndicatorOptions  Prepare Indicator options for Series/genip
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

MODELS = struct( );
MODELS.Level = @(x) x;
MODELS.Rate = @roc;
MODELS.Diff = @diff;
MODELS.DiffDiff = @(x) diff(diff(x));

%--------------------------------------------------------------------------

highRange = double(highRange);
highStart = highRange(1);
highEnd = highRange(end);
highFreq = DateWrapper.getFrequency(highStart);

indicator = struct( );
indicator.Model = hereResolveIndicatorModel( );
indicator.Level = [ ];
indicator.Transformed = [ ];
indicator.StdScale = double(options.StdScale);

invalidFreq = cell.empty(1, 0);

hereTryRetrieveLevel( );
if isempty(indicator.Transformed)
    hereTryRetrieveTransformed( );
end

if ~isempty(invalidFreq)
    thisError = [
        "Series:InvalidFrequencyGenip"
        "Date frequency of the time series assigned to the Indicator option %s= "
        "must match the target date frequency, which is %1. "
    ];
    throw(exception.Base(thisError, 'error'), char(highFreq), invalidFreq{:});
end

return

    function hereResolveIndicatorModel( )
        indicator.Model = options.Model;
        if isequal(indicator.Model, @auto)
            indicator.Model = model;
        end
    end%


    function hereTryRetrieveLevel( )
        if isa(options.Level, 'NumericTimeSubscriptable') && ~isempty(options.Level) 
            if isfreq(options.Level, highFreq)
                x__ = getDataFromTo(options.Level, highStart, highEnd);
                if ~all(isnan(x__(:)))
                    indicator.Level = x__;
                    func = MODELS.(model);
                    indicator.Transformed = getDataFromTo(func(options.Level), highStart, highEnd);
                end
            else
                invalidFreq{end+1} = 'Level';
            end
        end
    end%


    function hereTryRetrieveTransformed( )
        if isa(options.(model), 'NumericTimeSubscriptable') && ~isempty(options.(model)) 
            if isfreq(options.(model), highFreq)
                x = getDataFromTo(options.(model), highStart, highEnd);
                if ~all(isnan(x(:)))
                    indicator.Transformed = x;
                end
            else
                invalidFreq{end+1} = char(model);
            end
        end
    end%
end%

