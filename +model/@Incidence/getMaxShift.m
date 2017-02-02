function [maxLag, maxLead] = getMaxShift(this)
% getMaxShift  Actual max lag and max lead.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

%--------------------------------------------------------------------------

tZero = zero(this);
incid = across(this, 'Eqtn');
incid = any(incid, 1);
maxLag = find(incid, 1) - tZero;
maxLead = find(incid, 1, 'Last') - tZero;

end
