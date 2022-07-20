function [Obj, L, PP, SP, IsWithinBounds] = mylogpost(this, P)
% mylogpost  Evalute posterior density for given parameters
% this is a subfunction, and not a nested function, so that we can later
% implement a parfor loop (parfor does not work with nested functions).
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2022 IRIS Solutions Team & Troy Matheson

%--------------------------------------------------------------------------

Obj = 0;
L = 0;
PP = 0;
SP = 0;

% Check lower/upper bounds first.
indexOfLowerBounds = isfinite(this.Lower);
indexOfUpperBounds = isfinite(this.Upper);
IsWithinBounds = true;
if any(indexOfLowerBounds) || any(indexOfUpperBounds)
    % `P` is a column vector; `this.Lower` and `this.Upper` are row
    % vectors and need to be tranposed.
    IsWithinBounds = all( P(indexOfLowerBounds)>=this.Lower(indexOfLowerBounds).' ) ...
                     && all( P(indexOfUpperBounds)<=this.Upper(indexOfUpperBounds).' );
end

isValid = IsWithinBounds;

if IsWithinBounds
    if isa(this.MinusLogPostFunc, 'function_handle')
        % Evaluate log posterior.
        [Obj, L, PP, SP] = ...
            this.MinusLogPostFunc(P, this.MinusLogPostFuncArgs{:});
        Obj = -Obj;
        L = -L;
        PP = -PP;
        SP = -SP;
    else
        % Evaluate parameter priors.
        priorInx = cellfun(@(x) isa(x, 'function_handle'), this.LogPriorFunc);        
        for k = find(priorInx)
            PP = PP + this.LogPriorFunc{k}(P(k));
            if isinf(PP)
                Obj = Inf;
                return
            end
        end
        Obj = Obj + PP;
        if isa(this.MinusLogLikFunc, 'function_handle')
            % Evaluate minus log likelihood.
            L = this.MinusLogLikFunc(P, this.MinusLogLikFuncArgs{:});
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
