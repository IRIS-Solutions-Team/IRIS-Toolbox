function transition = prepareTransitionOptions(highRange, options)
% prepareTransitionOptions  Prepare Transition options for Series/genip
% 
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

highRange = double(highRange);
canHaveMissing = false;

transition = struct( );

if ~isequal(transition.Rate, @auto)
    transition.Rate = series.genip.validateTimeVaryingInput( ...
        "Transition.Rate", highRange, options.Rate, canHaveMissing ...
    );
end

if ~isequal(transition.Constant, @auto)
    transition.Constant = series.genip.validateTimeVaryingInput( ...
        "Transition.Constant", highRange, options.Constant, canHaveMissing ...
    );
end

end%

