function this = enforceLogStatus(this)
% enforceLogStatus  Enforce log status for quantities whose log status cannot be changed
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team

% Enforce false log status of shocks
inxEnforced = this.Type==31 | this.Type==32;
this.IxLog(inxEnforced) = false;

% Enforce false log status of time trend
inxTimeTrend = strcmp(this.Name, model.component.Quantity.RESERVED_NAME_TTREND);
this.IxLog(inxTimeTrend) = false;

end%

