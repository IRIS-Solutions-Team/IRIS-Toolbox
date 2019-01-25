function p = setAutoexog(p, type, quantity, lsExog, lsEndog)
% setAutoexog  Set autoexogenized parameter-variable or shock-variable pairs.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2019 IRIS Solutions Team.

TYPE = @int8;
PTR = @int16;
CAN_BE_EXOG = { TYPE(1), TYPE(2) };

switch type
    case 'dynamic'
        CAN_BE_ENDOG = { TYPE(31), TYPE(32) };
    case 'steady'
        CAN_BE_ENDOG = { TYPE(4) };
    otherwise
        throw( exception.Base('General:Internal', 'error') );
end

%--------------------------------------------------------------------------

if isempty(p)
    nQuan = length(quantity.Name);
    p = model.component.Pairing.initPointer(nQuan);
end

% Reset autoexogenize definitions.
p(:) = PTR(0);

lsNonExog = parser.getMultiple(lsExog);
if ~isempty(lsNonExog)
    throw( exception.Base('Pairing:MULTIPLE_LHS_AUTOEXOG', 'error'), ...
        lsNonExog{:} );
end

lsNonEndog = parser.getMultiple(lsEndog);
if ~isempty(lsNonEndog)
    throw( exception.Base('Pairing:MULTIPLE_RHS_AUTOEXOG', 'error'), ...
        lsNonEndog{:} );
end

ell = lookup(quantity, lsExog, CAN_BE_EXOG{:});
posExog = ell.PosName;
ixInvalidExog = isnan(ell.PosName);

ell = lookup(quantity, lsEndog, CAN_BE_ENDOG{:});
posEndog = ell.PosName;
ixInvalidEndog = isnan(ell.PosName);

ixInvalid = ixInvalidExog | ixInvalidEndog;
if any(ixInvalid)
    aux = strcat(lsExog, {' '}, lsEndog);
    switch type
        case 'dynamic'
            throw( ...
                exception.Base('Pairing:INVALID_NAMES_IN_DYNAMIC_AUTOEXOG', 'error'), ...
                aux{ixInvalid} ...
                );
        case 'steady'
            throw( ...
                exception.Base('Pairing:INVALID_NAMES_IN_STEADY_AUTOEXOG', 'error'), ...
                aux{ixInvalid} ...
                );
    end
end

p(posExog) = PTR(posEndog);
end
