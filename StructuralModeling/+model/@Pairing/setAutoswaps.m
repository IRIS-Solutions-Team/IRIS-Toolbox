% setAutoswaps  Set parameter-variable or shock-variable autoswap pairs
%
% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function p = setAutoswaps(p, type, quantity, namesToExogenize, namesToEndogenize)

PTR = @int16;
CAN_BE_EXOGENIZED = [1, 2];

type = lower(string(type));

if type=="simulate"
    CAN_BE_ENDOGENIZED = [31, 32];
elseif type=="steady"
    CAN_BE_ENDOGENIZED = 4;
else
    throw( exception.Base('General:Internal', 'error') );
end

if isempty(p)
    numQuantities = numel(quantity.Name);
    p = model.Pairing.initPointer(numQuantities);
end

% __Reset autoswap definitions__
p(:) = PTR(0);

[flag, exogenizedMoreThanOnce] = textual.nonunique(namesToExogenize);
if flag
    exception.error([
        "Pairing:ExogenizedMoreThanOnce"
        "This name is autoexogenized more than once: %s"
    ], string(exogenizedMoreThanOnce));
end

[flag, endogenizedMoreThanOnce] = textual.nonunique(namesToEndogenize);
if flag
    exception.error([
        "Pairing:EndogenizedMoreThanOnce"
        "This name is autoendogenized more than once: %s"
    ], string(endogenizedMoreThanOnce));
end

posToExogenize = lookupNames(quantity, namesToExogenize, "", CAN_BE_EXOGENIZED);
inxInvalidExog = isnan(posToExogenize);

posToEndogenize = lookupNames(quantity, namesToEndogenize, "", CAN_BE_ENDOGENIZED);
inxInvalidEndog = isnan(posToEndogenize);

inxInvalid = inxInvalidExog | inxInvalidEndog;
if any(inxInvalid)
    report = "[""" + string(namesToExogenize) + """, """ + string(namesToEndogenize) + """]";
    exception.error([
        "Pairing:InvalidAutoswapsNames"
        "These names cannot be paired in !autoswaps-%1: %s"
    ], type, report);
end

p(posToExogenize) = PTR(posToEndogenize);

end%
