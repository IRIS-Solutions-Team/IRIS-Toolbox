% changeLogStatus  Change log status of quantities
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function this = changeLogStatus(this, newStatus, namesToChange, varargin)

if isequal(namesToChange, @all)
    inxToChange = getIndexByType(this, varargin{:});
    this.IxLog(inxToChange) = newStatus;
    this = enforceLogStatus(this);
    return
end

namesToChange = string(namesToChange);
namesToChange(strlength(namesToChange)==0) = [ ];
if isempty(namesToChange)
    return
end

ell = lookup(this, cellstr(namesToChange), varargin{:});
inxNaN = isnan(ell.PosName);
if any(inxNaN)
    exception.error([
        "Quantity:CannotChangeLogStatus"
        "Cannot change the log status for this name: %s "
    ], namesToChange(inxNaN));
end

this.IxLog(ell.PosName) = newStatus;
this = enforceLogStatus(this);

end%

