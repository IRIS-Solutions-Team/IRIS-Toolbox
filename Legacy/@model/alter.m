function this = alter(this, numOfVariantsRequested)

nv = length(this);
if numOfVariantsRequested==nv
    % Do nothing.
    return
elseif nv==0 && numOfVariantsRequested>0
    if this.LinearStatus
        defaultStd = this.DEFAULT_STD_LINEAR;
    else
        defaultStd = this.DEFAULT_STD_NONLINEAR;
    end
    lenOfExpansion = 0;
    numOfHashed = nnz(this.Equation.IxHash);
    this.Variant = model.Variant( ...
        numOfVariantsRequested, this.Quantity, this.Vector, lenOfExpansion, numOfHashed, defaultStd ...
    );
elseif numOfVariantsRequested>nv
    % Expand nv by copying the last parameterisation.
    this.Variant = subscripted( ...
        this.Variant, nv+1:numOfVariantsRequested, ...
        this.Variant, nv*ones(1, numOfVariantsRequested-nv) ...
    );
else
    % Reduce nv by deleting the last parameterisations.
    this.Variant = subscripted(this.Variant, numOfVariantsRequested+1:nv, [ ]);
end

end
