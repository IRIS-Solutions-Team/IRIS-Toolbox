function ixAff = affected(this, iAlt, opt)
% affected  Equations affected by parameter changes since last system.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

%--------------------------------------------------------------------------

ixp = this.Quantity.Type==TYPE(4);
nEqtn = length(this.Equation.Input);

ixAff = true(1, nEqtn);
if ~opt.select
    return
end

value0 = this.LastSystem.Quantity;

% If last system does not exist, we must select all equations.
if nnz(this.LastSystem.Deriv.f)==0
    return
end

% Changes in steady states and parameters.
ixChanged = this.Variant{iAlt}.Quantity~=value0 ...
    & (~isnan(this.Variant{iAlt}.Quantity) | ~isnan(value0));
if this.IsLinear
    % Only parameter changes matter in linear models.
    ixChanged = ixChanged & ixp;
end

% Affected equations.
ind0 = across(this.Incidence.Dynamic, 'Zero'); % Incidence at zero.
ixAff = any(ind0(:, ixChanged), 2).';

end
