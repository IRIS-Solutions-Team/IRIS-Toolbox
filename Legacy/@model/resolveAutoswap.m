% resolveAutoswap  Resolve autoexogenize and autoendogenize options
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2022 [IrisToolbox] Solutions Team

function [namesToExogenize, namesToEndogenize] = resolveAutoswap(this, kind, namesToExogenize, namesToEndogenize)

PTR = @int16;

if startsWith(kind, "simulate", "ignoreCase", true)
    ptrAutoswaps = this.Pairing.Autoswaps.Simulate;
elseif startsWith(kind, "steady", "ignoreCase", true)
    ptrAutoswaps = this.Pairing.Autoswaps.Steady;
else
    ptrAutoswaps = [ ];
end

isAutoExogenize = isequal(namesToExogenize, @auto);
isAutoEndogenize = isequal(namesToEndogenize, @auto);

if ~isAutoExogenize
    namesToExogenize = string(namesToExogenize);
    if isscalar(namesToExogenize) && strlength(namesToExogenize)>0
        namesToExogenize = regexp(namesToExogenize, "\w+", "match");
    end    
end

if ~isAutoEndogenize
    namesToEndogenize = string(namesToEndogenize);
    if isscalar(namesToEndogenize) && strlength(namesToEndogenize)>0
        namesToEndogenize = regexp(namesToEndogenize, "\w+", "match");
    end
end

if isstring(namesToExogenize) && ~isempty(namesToExogenize) && any(strlength(namesToExogenize)>0)
    ellExogenize = lookup(this.Quantity, cellstr(namesToExogenize));
    inxValid = isfinite(ellExogenize.PosName);
    if any(~inxValid)
        exception.error([
            "Model:CannotExogenize"
            "This name cannot be exogenized: %s"
        ], namesToExogenize(~inxValid));
    end
end

if isstring(namesToEndogenize) && ~isempty(namesToEndogenize) && any(strlength(namesToEndogenize)>0)
    ellEndogenize = lookup(this.Quantity, cellstr(namesToEndogenize));
    inxValid = isfinite(ellEndogenize.PosName);
    if any(~inxValid)
        exception.error([
            "Model:CannotEndogenize"
            "This name cannot be endogenized: %s"
        ], namesToEndogenize(~inxValid));
    end
end

if isAutoExogenize && isAutoEndogenize
    % Use all exogenized-endogenized names
    ix = ptrAutoswaps>PTR(0);
    ptr = ptrAutoswaps(ix);
    namesToExogenize = this.Quantity.Name(ix);
    namesToEndogenize = this.Quantity.Name(ptr);
elseif isAutoEndogenize
    % List of exogenized names, look up the corresponding endogenized names
    ptr = ptrAutoswaps( ellExogenize.PosName );
    inxValid = ptr>PTR(0);
    if any(~inxValid)
        exception.error([
            "Model:CannotAutoexogenize"
            "This name cannot be autoexogenized: %s"
        ], namesToExogenize(~inxValid));
    end
    namesToEndogenize = this.Quantity.Name(ptr);
elseif isAutoExogenize
    % List of endogenized names, look up the corresponding exogenized names
    ptr = ellEndogenize.PosName;
    nPtr = numel(ptr);
    pos = nan(1, nPtr);
    for i = 1 : nPtr
        ix = PTR(ptr(i))==ptrAutoswaps;
        inxValid(i) = any(ix);
        if inxValid(i)
            pos(i) = find(ix);
        end
    end
    if any(~inxValid)
        exception.error([
            "Model:CannotAutoendogenize"
            "This name cannot be autoendogenized: %s"
        ], namesToEndogenize(~inxValid));
    end
    namesToExogenize = this.Quantity.Name(pos);
end

end%

