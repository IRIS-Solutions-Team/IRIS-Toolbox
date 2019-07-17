function this = enforceLogStatus(this)
% enforceLogStatus  Enforce log status for quantities whose log status cannot be changed
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

TYPE = @int8;

%--------------------------------------------------------------------------

% Enforce false log status of shocks
inxOfEnforced = this.Type==TYPE(31) | this.Type==TYPE(32);
this.IxLog(inxOfEnforced) = false;

% Enforce false log status of time trend
inxOfTimeTrend = strcmp(this.Name, this.RESERVED_NAME_TTREND);
this.IxLog(inxOfTimeTrend) = false;

end%

