function this = changeLogStatus(this, newStatus, namesToChange, varargin)
% changeLogStatus  Change log status of names
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

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

ell = lookup(this, namesToChange, varargin{:});
inxOfNaN = isnan(ell.PosName);
if any(inxOfNaN)
    THIS_ERROR = { 'Quantity:CannotChangeLogStatus'
                   'Cannot change the log status for this name: %s ' };
    throw( exception.Base(THIS_ERROR, 'error'), ...
           namesToChange{inxOfNaN} );
end

this.InxOfLog(ell.PosName) = newStatus;
this = enforceLogStatus(this);

end%

