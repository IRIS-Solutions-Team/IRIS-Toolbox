% prepareIndicatorOptions  Prepare Indicator options for Series/genip
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function indicator = prepareIndicatorOptions(transition, ~, highRange, ~, opt)

MODELS = struct( );
MODELS.Level = @(x) x;
MODELS.Rate = @roc;
MODELS.Diff = @diff;
MODELS.DiffDiff = @(x) diff(diff(x));

%--------------------------------------------------------------------------

numInit = transition.NumInit;
highRange = double(highRange);
highStart = highRange(1);
highExtStart = dater.plus(highStart, -numInit);
highEnd = highRange(end);
highFreq = DateWrapper.getFrequency(highStart);

indicator = struct( );
indicator.Model = locallyResolveIndicatorModel(opt.Indicator_Model);
indicator.Level = hereTryRetrieveLevel( );

return


    function level = hereTryRetrieveLevel( )
        %(
        level = [ ];
        if isa(opt.Indicator_Level, 'NumericTimeSubscriptable') && ~isempty(opt.Indicator_Level) 
            if isfreq(opt.Indicator_Level, highFreq)
                x__ = getDataFromTo(opt.Indicator_Level, highExtStart, highEnd);
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
