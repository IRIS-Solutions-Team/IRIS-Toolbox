% prepareIndicatorOptions  Prepare Indicator options for Series/genip
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function indicator = prepareIndicatorOptions(transition, ~, highRange, ~, opt)

    MODELS = struct();
    MODELS.Level = @(x) x;
    MODELS.Rate = @roc;
    MODELS.Diff = @diff;
    MODELS.DiffDiff = @(x) diff(diff(x));


    numInit = transition.NumInit;
    highRange = double(highRange);
    highStart = highRange(1);
    highExtStart = dater.plus(highStart, -numInit);
    highEnd = highRange(end);
    highFreq = dater.getFrequency(highStart);

    indicator = struct();
    indicator.Model = local_resolveIndicatorModel(opt.IndicatorModel);
    indicator.Level = here_tryRetrieveLevel();

return

    function level = here_tryRetrieveLevel()
        %(
        level = [ ];
        if isa(opt.IndicatorLevel, 'Series') && ~isempty(opt.IndicatorLevel) 
            if isfreq(opt.IndicatorLevel, highFreq)
                x__ = getDataFromTo(opt.IndicatorLevel, highExtStart, highEnd);
                inxNaN = ~isfinite(x__(:));
                if all(inxNaN)
                    return
                end
                level = x__;
            else
                throw(exception.Base([
                    "Genip:InvalidFrequencyIndicator"
                    "Date frequency of the time series supplied as Indicator.Level= "
                    "must match the target date frequency, which is %s. "
                ], "error"), string(highFreq));
            end
        end
        %)
    end%
end%


function indicatorModel = local_resolveIndicatorModel(indicatorModel)
    %(
    if startsWith(indicatorModel, "rat", "ignoreCase", true)
        indicatorModel = "ratio";
    elseif startsWith(indicatorModel, "diff", "ignoreCase", true)
        indicatorModel = "difference";
    end
    %)
end%

