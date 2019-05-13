function this = changeLogStatus(this, namesToChange, newStatus)
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
    this.IxLog(:) = newStatus;
    return
end

if ischar(namesToChange)
    namesToChange = regexp(namesToChange, '\w+', 'match');
    if isempty(namesToChange)
        return
    end
end

ell = lookup(this, namesToChange, TYPE(1), TYPE(2), TYPE(4), TYPE(5));
ixNan = isnan(ell.PosName);
if any(ixNan)
    THIS_ERROR = { 'Quantity:CannotChangeLogStatus'
                   'Cannot change log-status for this name: %s ' };
    throw( exception.Base(THIS_ERROR, 'error'), ...
           namesToChange{ixNan} );
end

this.IxLog(ell.PosName) = newStatus;

end%

