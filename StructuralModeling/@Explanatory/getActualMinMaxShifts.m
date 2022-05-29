function [minSh, maxSh] = getActualMinMaxShifts(this)
% getActualMinMaxShifts  Actual minimum and maximum shifts across steady equations
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

%--------------------------------------------------------------------------

minSh = min([0, this(:).MaxLag]);
maxSh = max([0, this(:).MaxLead]);

end%

