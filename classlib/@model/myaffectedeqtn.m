function ixAffected = myaffectedeqtn(this, iAlt, opt)
% myaffectedeqtn  Equations affected by parameter changes since last system.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

TYPE = @int8;

if isequal(opt.linear, @auto)
    opt.linear = this.IsLinear;
end

%--------------------------------------------------------------------------

ixp = this.Quantity.Type==TYPE(4);
nEqtn = length(this.Equation.Input);

ixAffected = true(1, nEqtn);
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
if opt.linear
    % Only parameter changes matter in linear models.
    ixChanged = ixChanged & ixp;
end

% Affected equations.
ind0 = across(this.Incidence.Dynamic, 'Zero'); % Incidence at zero.
ixAffected = any(ind0(:, ixChanged), 2).';

end
