function this = changeLogStatus(this, newStatus, namesToChange, varargin)
% changeLogStatus  Change log status of quantities
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

TYPE = @int8;

%--------------------------------------------------------------------------

if isempty(namesToChange)
    return
end

if isequal(namesToChange, @all)
    inxToChange = getIndexByType(this, varargin{:});
    this.IxLog(inxToChange) = newStatus;
    this = enforceLogStatus(this);
    return
end

if ischar(namesToChange)
    namesToChange = regexp(namesToChange, '\w+', 'match');
    if isempty(namesToChange)
        return
    end
end

%
% Remove empty entries from the list
%
inxEmpty = cellfun(@(x) strlength(x)==0, namesToChange);
namesToChange(inxEmpty) = [ ];

ell = lookup(this, namesToChange, varargin{:});
inxNaN = isnan(ell.PosName);
if any(inxNaN)
    thisError = [
        "Quantity:CannotChangeLogStatus"
        "Cannot change the log status for this name: %s "
    ];
    throw(exception.Base(thisError, 'error'), namesToChange{inxNaN});
end

this.IxLog(ell.PosName) = newStatus;
this = enforceLogStatus(this);

end%

