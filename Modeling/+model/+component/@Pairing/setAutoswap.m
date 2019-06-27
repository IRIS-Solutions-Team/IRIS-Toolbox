function p = setAutoswap(p, type, quantity, lsExog, lsEndog)
% setAutoswap  Set autoexogenized parameter-variable or shock-variable pairs
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

TYPE = @int8;
PTR = @int16;
CAN_BE_EXOGENIZED = { TYPE(1), TYPE(2) };

if strcmpi(type, 'Simulate')
    CAN_BE_ENDOGENIZED = { TYPE(31), TYPE(32) };
elseif strcmpi(type, 'Steady')
    CAN_BE_ENDOGENIZED = { TYPE(4) };
else
    throw( exception.Base('General:Internal', 'error') );
end

%--------------------------------------------------------------------------

if isempty(p)
    numOfQuantities = length(quantity.Name);
    p = model.component.Pairing.initPointer(numOfQuantities);
end

% Reset autoswap definitions
p(:) = PTR(0);

moreThanOnceExogenized = parser.getMultiple(lsExog);
if ~isempty(moreThanOnceExogenized)
    throw( exception.Base('Pairing:MULTIPLE_LHS_AUTOEXOG', 'error'), ...
           moreThanOnceExogenized{:} );
end

moreThanOnceEndogenized = parser.getMultiple(lsEndog);
if ~isempty(moreThanOnceEndogenized)
    throw( exception.Base('Pairing:MULTIPLE_RHS_AUTOEXOG', 'error'), ...
           moreThanOnceEndogenized{:} );
end

ell = lookup(quantity, lsExog, CAN_BE_EXOGENIZED{:});
posExog = ell.PosName;
inxOfInvalidExog = isnan(ell.PosName);

ell = lookup(quantity, lsEndog, CAN_BE_ENDOGENIZED{:});
posEndog = ell.PosName;
inxOfInvalidEndog = isnan(ell.PosName);

inxOfInvalid = inxOfInvalidExog | inxOfInvalidEndog;
if any(inxOfInvalid)
    aux = strcat(lsExog, {' '}, lsEndog);
    if strcmpi(type, 'Simulate')
        throw( exception.Base('Pairing:INVALID_NAMES_IN_DYNAMIC_AUTOEXOG', 'error'), ...
               aux{inxOfInvalid} );
    elseif strcmpi(type, 'Steady')
        throw( exception.Base('Pairing:INVALID_NAMES_IN_STEADY_AUTOEXOG', 'error'), ...
               aux{inxOfInvalid} );
    end
end

p(posExog) = PTR(posEndog);

end%

