function transition = prepareTransitionOptions(transitionModel, highRange, opt)
% prepareTransitionOptions  Prepare Transition opt for Series/genip
% 
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

highRange = double(highRange);
highStart = highRange(1);
highEnd = highRange(end);
canHaveMissing = false;

transition = struct( );
transition.Model = transitionModel;
transition.Rate = opt.Rate;
transition.Constant = opt.Constant;

if ~isequal(transition.Rate, @auto)
    transition.Rate = series.genip.validateTimeVaryingInput( ...
        "Transition.Rate", highRange, opt.Rate, canHaveMissing ...
    );
end

if ~isequal(transition.Constant, @auto)
    transition.Constant = series.genip.validateTimeVaryingInput( ...
        "Transition.Constant", highRange, opt.Constant, canHaveMissing ...
    );
end

if isa(opt.Std, 'NumericTimeSubscriptable')
    transition.Std = getDataFromTo(opt.Std, highStart, highEnd);
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

