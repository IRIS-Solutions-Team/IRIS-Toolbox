%{
% 
% # `alter` ^^(Model)^^
% 
% {== Expand or reduce number of parameter variants in model object ==}
% 
% 
% ## Syntax 
% 
%     M = alter(M, N)
% 
% 
% ## Input arguments 
% 
% `M` [ model ]
% > 
% > Model object in which the number of parameter variants
% > will be changed.
% > 
% 
% `N` [ numeric ]
% > 
% > New number of model variants.
% > 
% 
% 
% ## Output arguments 
% 
% `M` [ model ]
% > 
% > Model object with the new number of variants.
% > 
% 
% 
% ## Description 
% 
% If the new number of parameter variants, `N`, is greater than the current
% number of parameter variants in the model object, `M`, the last parameter
% variant (including solution matrices, if available) is copied an
% appropriate number of times.
% 
% If the new number of parameter variants, `N`, is smaller than the current
% number of parameter variants in the model object, `M`, an appropriate
% number of parameter variants is deleted from the end.
% 
% 
% 
% ## Examples
% 
% 
%}
% --8<--


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
