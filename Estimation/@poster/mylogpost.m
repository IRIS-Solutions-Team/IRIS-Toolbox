function [Obj,L,PP,SP,IsWithinBounds] = mylogpost(This,P)
% mylogpost  Evalute posterior density for given parameters.
% This is a subfunction, and not a nested function, so that we can later
% implement a parfor loop (parfor does not work with nested functions).
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2018 IRIS Solutions Team & Troy Matheson.

%--------------------------------------------------------------------------

Obj = 0;
L = 0;
PP = 0;
SP = 0;

% Check lower/upper bounds first.
lowerInx = isfinite(This.Lower);
upperInx = isfinite(This.Upper);
IsWithinBounds = true;
if any(lowerInx) || any(upperInx)
    % `P` is a column vector; `This.Lower` and `This.Upper` are row
    % vectors and need to be tranposed.
    IsWithinBounds = all(P(lowerInx) >= This.Lower(lowerInx).') ...
        && all(P(upperInx) <= This.Upper(upperInx).');
end

isValid = IsWithinBounds;

if IsWithinBounds
    if isa(This.MinusLogPostFunc,'function_handle')
        % Evaluate log posterior.
        [Obj,L,PP,SP] = ...
            This.MinusLogPostFunc(P,This.MinusLogPostFuncArgs{:});
        Obj = -Obj;
        L = -L;
        PP = -PP;
        SP = -SP;
    else
        % Evaluate parameter priors.
        priorInx = cellfun(@isfunc,This.LogPriorFunc);        
        for k = find(priorInx)
            PP = PP + This.LogPriorFunc{k}(P(k));
            if isinf(PP)
                Obj = Inf;
                return
            end
        end
        Obj = Obj + PP;
        if isa(This.MinusLogLikFunc,'function_handle')
            % Evaluate minus log likelihood.
            L = This.MinusLogLikFunc(P,This.MinusLogLikFuncArgs{:});
            L = -L;
            Obj = Obj + L;
        end
    end
    isValid = isnumeric(Obj) && length(Obj) == 1 ...
        && isfinite(Obj) && imag(Obj) == 0;
end

if ~isValid
    Obj = -Inf;
end

end
