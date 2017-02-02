function this = chgLogStatus(this, lsName, newStatus)
% chgLogStatus  Change log status of names.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

%--------------------------------------------------------------------------

if isempty(lsName)
    return
end

if isequal(lsName, @all)
    this.IxLog(:) = newStatus;
    return
end

if ischar(lsName)
    lsName = regexp(lsName, '\w+', 'match');
    if isempty(lsName)
        return
    end
end

ell = lookup(this, lsName, TYPE(1), TYPE(2));
ixNan = isnan(ell.PosName);
if any(ixNan)
    throw( exception.Base('Quantity:CANNOT_UNLOG', 'error'), ...
        lsName{ixNan} );
end

this.IxLog(ell.PosName) = newStatus;

end