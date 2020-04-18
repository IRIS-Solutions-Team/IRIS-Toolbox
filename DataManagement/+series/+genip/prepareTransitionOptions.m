function transition = prepareTransitionOptions(transitionModel, highRange, opt)
% prepareTransitionOptions  Prepare Transition opt for Series/genip
% 
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

highRange = double(highRange);
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

end%

