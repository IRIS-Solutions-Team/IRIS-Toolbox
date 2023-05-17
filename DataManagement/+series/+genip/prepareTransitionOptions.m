% prepareTransitionOptions  Prepare Transition opt for Series/genip
% 
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function transition = prepareTransitionOptions(transition, aggregation, highRange, lowLevel, opt)

    numInit = 2;
    highRange = double(highRange);
    highStartInit = highRange(1) - numInit;
    highEnd = highRange(end);
    canHaveMissing = false;

    transition.NumInit = numInit;
    % transition.Rate = opt.TransitionRate;
    % if isequal(transition.Rate, @auto)
    %     transitionRate = series.genip.fitTransitionRate(aggregation, lowLevel);
    % end

    transition.Intercept = opt.TransitionIntercept;
    transition.Std = opt.TransitionStd;

    if isa(transition.Std, 'Series')
        transition.Std = getDataFromTo(transition.Std, highStartInit, highEnd);
        transition.Std = abs(transition.Std);
        inxNaN = isnan(transition.Std);
        if any(inxNaN(:))
            transition.Std(inxNaN) = 1;
        end
        transition.Std = transition.Std / transition.Std(1);
        transition.Std = reshape(transition.Std, 1, 1, []);
    else
        transition.Std = [];
    end

end%

