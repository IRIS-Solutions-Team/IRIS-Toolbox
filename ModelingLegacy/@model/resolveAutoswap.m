function [namesOfExogenized, namesOfEndogenized] = resolveAutoswap(this, kind, namesOfExogenized, namesOfEndogenized)
% resolveAutoswap  Resolve autoexogenize and autoendogenize options
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2020 IRIS Solutions Team

PTR = @int16;

%--------------------------------------------------------------------------

if strcmpi(kind, 'Simulate')
    ptrAutoswap = this.Pairing.Autoswap.Simulate;
elseif strcmpi(kind, 'Steady')
    ptrAutoswap = this.Pairing.Autoswap.Steady;
end

isExgAuto = isequal(namesOfExogenized, @auto);
isEndgAuto = isequal(namesOfEndogenized, @auto);
if ischar(namesOfExogenized)
    namesOfExogenized = regexp(namesOfExogenized, '\w+', 'match');
end
if ischar(namesOfEndogenized)
    namesOfEndogenized = regexp(namesOfEndogenized, '\w+', 'match');
end
if iscellstr(namesOfExogenized)
    ellExg = lookup(this.Quantity, namesOfExogenized);
    inxOfValid = isfinite(ellExg.PosName);
    if any(~inxOfValid)
        throw( exception.Base('Blazer:CannotExogenize', 'error'), ...
               namesOfExogenized{~inxOfValid} );
    end
end
if iscellstr(namesOfEndogenized)
    ellEndg = lookup(this.Quantity, namesOfEndogenized);
    inxOfValid = isfinite(ellEndg.PosName);
    if any(~inxOfValid)
        throw( exception.Base('Blazer:CannotEndogenize', 'error'), ...
               namesOfEndogenized{~inxOfValid} );
    end
end

if isExgAuto && isEndgAuto
    % Use all exogenized-endogenized names
    ix = ptrAutoswap>PTR(0);
    ptr = ptrAutoswap(ix);
    namesOfExogenized = this.Quantity.Name(ix);
    namesOfEndogenized = this.Quantity.Name(ptr);
elseif isEndgAuto
    % List of exogenized names, look up the corresponding endogenized names
    ptr = ptrAutoswap( ellExg.PosName );
    inxOfValid = ptr>PTR(0);
    if any(~inxOfValid)
        throw( exception.Base('Blazer:CannotAutoexogenize', 'error'), ...
               namesOfExogenized{~inxOfValid} );
    end
    namesOfEndogenized = this.Quantity.Name(ptr);
elseif isExgAuto
    % List of endogenized names, look up the corresponding exogenized names
    ptr = ellEndg.PosName;
    nPtr = numel(ptr);
    pos = nan(1, nPtr);
    for i = 1 : nPtr
        ix = PTR(ptr(i))==ptrAutoswap;
        inxOfValid(i) = any(ix);
        if inxOfValid(i)
            pos(i) = find(ix);
        end
    end
    if any(~inxOfValid)
        throw( exception.Base('Blazer:CannotAutoendogenize', 'error'), ...
               namesOfEndogenized{~inxOfValid} );
    end
    namesOfExogenized = this.Quantity.Name(pos);
end

end%

