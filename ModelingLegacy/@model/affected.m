function indexEquationsAffected = affected(this, variantRequested, opt)
% affected  Equations affected by parameter changes since last system
%
% Backend IRIS function
% No help provided

% -IRIS Macroeconomic Modeling Toolbox
% -Copyright (c) 2007-2019 IRIS Solutions Team

TYPE = @int8;

%--------------------------------------------------------------------------

ixp = this.Quantity.Type==TYPE(4);
nEqtn = length(this.Equation.Input);

indexEquationsAffected = true(1, nEqtn);
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
indexChanged = currentValues~=lastValues & (~isnan(currentValues) | ~isnan(lastValues));
if this.IsLinear
    % Only parameter changes matter in linear models
    indexChanged = indexChanged & ixp;
end

% Affected equations
indexEquationsAffected = any( this.Affected(:, indexChanged), 2 ).';

end
