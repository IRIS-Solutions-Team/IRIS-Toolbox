function inxEquationsAffected = affected(this, variantRequested, opt)
% affected  Equations affected by parameter changes since last system
%
% Backend [IrisToolbox] method
% No help provided

% -[IrisToolbox] for Macroeconomic Modeling
% -Copyright (c) 2007-2020 [IrisToolbox] Solutions Team

TYPE = @int8;

%--------------------------------------------------------------------------

inxP = this.Quantity.Type==TYPE(4);
numEquations = length(this.Equation.Input);

inxEquationsAffected = true(1, numEquations);
if ~opt.Select
    return
end

lastValues = this.LastSystem.Values;

% If last system does not exist, we must select all equations
if nnz(this.LastSystem.Deriv.f)==0
    return
end

% Changes in steady states and parameters
currentValues = this.Variant.Values(:, :, variantRequested);
inxChanged = currentValues~=lastValues & (~isnan(currentValues) | ~isnan(lastValues));
if this.IsLinear
    % Only parameter changes matter in linear models
    inxChanged = inxChanged & inxP;
end

% Affected equations
inxEquationsAffected = any( this.Affected(:, inxChanged), 2 ).';

end%

