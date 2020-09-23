% resolveAutoswap  Resolve autoexogenize and autoendogenize options
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

function [namesExogenized, namesEndogenized] = resolveAutoswap(this, kind, namesExogenized, namesEndogenized)

PTR = @int16;

%--------------------------------------------------------------------------

if startsWith(kind, "simulate", "ignoreCase", true)
    ptrAutoswap = this.Pairing.Autoswap.Simulate;
elseif startsWith(kind, "steady", "ignoreCase", true)
    ptrAutoswap = this.Pairing.Autoswap.Steady;
else
    ptrAutoswap = [ ];
end

isExgAuto = isequal(namesExogenized, @auto);
isEndgAuto = isequal(namesEndogenized, @auto);
if ischar(namesExogenized)
    namesExogenized = regexp(namesExogenized, '\w+', 'match');
end
if ischar(namesEndogenized)
    namesEndogenized = regexp(namesEndogenized, '\w+', 'match');
end
if iscellstr(namesExogenized)
    ellExg = lookup(this.Quantity, namesExogenized);
    inxValid = isfinite(ellExg.PosName);
    if any(~inxValid)
        throw( exception.Base('Blazer:CannotExogenize', 'error'), ...
               namesExogenized{~inxValid} );
    end
end
if iscellstr(namesEndogenized)
    ellEndg = lookup(this.Quantity, namesEndogenized);
    inxValid = isfinite(ellEndg.PosName);
    if any(~inxValid)
        throw( exception.Base('Blazer:CannotEndogenize', 'error'), ...
               namesEndogenized{~inxValid} );
    end
end

if isExgAuto && isEndgAuto
    % Use all exogenized-endogenized names
    ix = ptrAutoswap>PTR(0);
    ptr = ptrAutoswap(ix);
    namesExogenized = this.Quantity.Name(ix);
    namesEndogenized = this.Quantity.Name(ptr);
elseif isEndgAuto
    % List of exogenized names, look up the corresponding endogenized names
    ptr = ptrAutoswap( ellExg.PosName );
    inxValid = ptr>PTR(0);
    if any(~inxValid)
        throw( exception.Base('Blazer:CannotAutoexogenize', 'error'), ...
               namesExogenized{~inxValid} );
    end
    namesEndogenized = this.Quantity.Name(ptr);
elseif isExgAuto
    % List of endogenized names, look up the corresponding exogenized names
    ptr = ellEndg.PosName;
    nPtr = numel(ptr);
    pos = nan(1, nPtr);
    for i = 1 : nPtr
        ix = PTR(ptr(i))==ptrAutoswap;
        inxValid(i) = any(ix);
        if inxValid(i)
            pos(i) = find(ix);
        end
    end
    if any(~inxValid)
        throw( exception.Base('Blazer:CannotAutoendogenize', 'error'), ...
               namesEndogenized{~inxValid} );
    end
    namesExogenized = this.Quantity.Name(pos);
end

end%

