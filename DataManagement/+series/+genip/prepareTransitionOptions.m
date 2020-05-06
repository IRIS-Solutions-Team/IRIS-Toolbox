function transition = prepareTransitionOptions(transition, highRange, opt)
% prepareTransitionOptions  Prepare Transition opt for Series/genip
% 
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

numInit = transition.Order;
highRange = double(highRange);
highStart = highRange(1);
highEnd = highRange(end);
canHaveMissing = false;

transition.Rate = opt.TransitionRate;
transition.Intercept = opt.TransitionIntercept;
transition.Std = opt.TransitionStd;

if isa(transition.Std, 'NumericTimeSubscriptable')
    transition.Std = getDataFromTo(transition.Std, highStart, highEnd);
    transition.Std = abs(transition.Std);
    if any(isnan(transition.Std(:)))
        transition.Std = numeric.fillMissing(transition.Std, NaN, 'globalLoglinear');
    end
    transition.Std = transition.Std/transition.Std(1);
    transition.Std = reshape(transition.Std, 1, 1, [ ]);
else
    transition.Std = 1;
end

end%

