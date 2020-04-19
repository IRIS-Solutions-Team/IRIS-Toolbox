function indicator = prepareIndicatorOptions(transitionModel, highRange, options)
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

hereCheckDimensions( );

if ~isempty(invalidFreq)
    thisError = [
        "Genip:InvalidFrequencyIndicator"
        "Date frequency of the time series assigned to the Indicator option %s= "
        "must match the target date frequency, which is %1. "
    ];
    throw(exception.Base(thisError, 'error'), char(highFreq), invalidFreq{:});
end

return

    function indicatorModel = hereResolveIndicatorModel( )
        indicatorModel = options.Model;
        if isequal(indicatorModel, @auto)
            indicatorModel = transitionModel;
        end
    end%


    function hereTryRetrieveLevel( )
        model = indicator.Model;
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
        model = indicator.Model;
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


    function hereCheckDimensions( )
        numStd = numel(indicator.StdScale);
        numTransformed = size(indicator.Transformed, 2);
        if numStd>1 && numStd~=numTransformed
            thisError = [
                "Genip:InvalidDimensionsIndicator"
                "Number of elements in Indicator.Std= is not consistent "
                "with the dimensions of Indicator.Level= or Indicator.%g=."
            ];
            throw(exception.Base(thisError, 'error'), indicator.Model);
        end
    end%
end%

