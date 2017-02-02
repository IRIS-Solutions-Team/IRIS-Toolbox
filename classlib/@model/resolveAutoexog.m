function [lsExg, lsEndg] = resolveAutoexog(this, kind, lsExg, lsEndg)
% resolveAutoexog  Resolve autoexogenize and autoendogenize options.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

PTR = @int16;

%--------------------------------------------------------------------------

switch lower(kind)
    case 'dynamic'
        ptrAutoexog = this.Pairing.Autoexog.Dynamic;
    case 'steady'
        ptrAutoexog = this.Pairing.Autoexog.Steady;
end

isExgAuto = isequal(lsExg, @auto);
isEndgAuto = isequal(lsEndg, @auto);
if ischar(lsExg)
    lsExg = regexp(lsExg, '\w+', 'match');
end
if ischar(lsEndg)
    lsEndg = regexp(lsEndg, '\w+', 'match');
end
if iscellstr(lsExg)
    ellExg = lookup(this.Quantity, lsExg);
    ixValid = isfinite(ellExg.PosName);
    if any(~ixValid)
        throw( exception.Base('Blazer:CannotExogenize', 'error'), ...
            lsExg{~ixValid} );
    end
end
if iscellstr(lsEndg)
    ellEndg = lookup(this.Quantity, lsEndg);
    ixValid = isfinite(ellEndg.PosName);
    if any(~ixValid)
        throw( exception.Base('Blazer:CannotEndogenize', 'error'), ...
            lsEndg{~ixValid} );
    end
end

if isExgAuto && isEndgAuto
    % Use all exogenized-endogenized names.
    ix = ptrAutoexog>PTR(0);
    ptr = ptrAutoexog(ix);
    lsExg = this.Quantity.Name(ix);
    lsEndg = this.Quantity.Name(ptr);
elseif isEndgAuto
    % List of exogenized names, look up the corresponding endogenized names.
    ptr = ptrAutoexog( ellExg.PosName );
    ixValid = ptr>PTR(0);
    if any(~ixValid)
        throw( exception.Base('Blazer:CannotAutoexogenize', 'error'), ...
            lsExg{~ixValid} );
    end
    lsEndg = this.Quantity.Name(ptr);
elseif isExgAuto
    % List of endogenized names, look up the corresponding exogenized names.
    ptr = ellEndg.PosName;
    nPtr = numel(ptr);
    pos = nan(1, nPtr);
    for i = 1 : nPtr
        ix = PTR(ptr(i))==ptrAutoexog;
        ixValid(i) = any(ix);
        if ixValid(i)
            pos(i) = find(ix);
        end
    end
    if any(~ixValid)
        throw( exception.Base('Blazer:CannotAutoendogenize', 'error'), ...
            lsEndg{~ixValid} );
    end
    lsExg = this.Quantity.Name(pos);
end

end
