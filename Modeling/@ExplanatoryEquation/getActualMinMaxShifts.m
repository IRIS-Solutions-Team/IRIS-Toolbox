function [minSh, maxSh] = getActualMinMaxShifts(this)
% getActualMinMaxShifts  Actual minimum and maximum shifts across steady equations
%
% Backend IRIS method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 IRIS Solutions Team

%--------------------------------------------------------------------------

minSh = min([0, this(:).MaxLag]);
maxSh = max([0, this(:).MaxLead]);

end%

