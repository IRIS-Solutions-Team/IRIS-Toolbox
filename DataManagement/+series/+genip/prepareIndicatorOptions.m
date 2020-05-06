function indicator = prepareIndicatorOptions(transition, highRange, opt)
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

numInit = transition.Order;
highRange = double(highRange);
highStart = highRange(1);
highExtStart = DateWrapper.roundPlus(highStart, -numInit);
highEnd = highRange(end);
highFreq = DateWrapper.getFrequency(highStart);

indicator = struct( );
indicator.Model = locallyResolveIndicatorModel(opt.IndicatorModel);
indicator.Level = hereTryRetrieveLevel( );

return


    function level = hereTryRetrieveLevel( )
        %(
        level = [ ];
        if isa(opt.IndicatorLevel, 'NumericTimeSubscriptable') && ~isempty(opt.IndicatorLevel) 
            if isfreq(opt.IndicatorLevel, highFreq)
                x__ = getDataFromTo(opt.IndicatorLevel, highExtStart, highEnd);
                inxNaN = ~isfinite(x__(:));
                if all(inxNaN)
                    return
                end
                level = x__;
            else
                thisError = [
                    "Genip:InvalidFrequencyIndicator"
                    "Date frequency of the time series supplied as Indicator.Level= "
                    "must match the target date frequency, which is %s. "
                ];
                throw(exception.Base(thisError, 'error'), char(highFreq));
            end
        end
        %)
    end%
end%


%
% Local Functions
%


function indicatorModel = locallyResolveIndicatorModel(indicatorModel)
    if startsWith(indicatorModel, "Rat")
        indicatorModel = "Ratio";
    elseif startsWith(indicatorModel, "Diff")
        indicatorModel = "Difference";
    end
end%
