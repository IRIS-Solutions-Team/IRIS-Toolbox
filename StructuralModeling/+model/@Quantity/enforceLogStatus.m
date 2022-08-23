% enforceLogStatus  Enforce log status for quantities whose log status cannot be changed
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function this = enforceLogStatus(this)

    % Enforce false log status of shocks
    inxEnforced = this.Type==31 | this.Type==32;
    this.IxLog(inxEnforced) = false;

    % Enforce false log status of time trend
    inxTimeTrend = string(this.Name)==string(model.Quantity.RESERVED_NAME_TTREND);
    this.IxLog(inxTimeTrend) = false;

end%

