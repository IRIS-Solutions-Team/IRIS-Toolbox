% prepareTransitionOptions  Prepare Transition opt for Series/genip
% 
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function transition = prepareTransitionOptions(transition, aggregation, highRange, lowLevel, opt)

%--------------------------------------------------------------------------

highRange = double(highRange);
highStart = highRange(1);
highEnd = highRange(end);
canHaveMissing = false;

transition.NumInit = 2;
transition.Rate = opt.Transition_Rate;
if isequal(transition.Rate, @auto)
    transition.Rate = series.genip.fitTransitionRate(aggregation, lowLevel);
end
    
transition.Intercept = opt.Transition_Intercept;
transition.Std = opt.Transition_Std;

if isa(transition.Std, "NumericTimeSubscriptable")
    transition.Std = getDataFromTo(transition.Std, highStart, highEnd);
    transition.Std = abs(transition.Std);
    inxNaN = isnan(transition.Std);
    if any(inxNaN(:))
        transition.Std = numeric.fillMissing(transition.Std, inxNaN, "regressLogTrend");
    end
    transition.Std = transition.Std/transition.Std(1);
    transition.Std = reshape(transition.Std, 1, 1, [ ]);
else
    transition.Std = 1;
end

end%

