function this = enforceLogStatus(this)
% enforceLogStatus  Enforce log status for quantities whose log status cannot be changed
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

TYPE = @int8;

%--------------------------------------------------------------------------

% Enforce false log status of shocks
inxEnforced = this.Type==TYPE(31) | this.Type==TYPE(32);
this.IxLog(inxEnforced) = false;

% Enforce false log status of time trend
inxTimeTrend = strcmp(this.Name, model.component.Quantity.RESERVED_NAME_TTREND);
this.IxLog(inxTimeTrend) = false;

end%

