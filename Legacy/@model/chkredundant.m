function [lsRedShock, lsRedParam] = chkredundant(this, varargin)

defaults = {
    'warning', true, @(x) isequal(x, true) || isequal(x, false)
    'chkshock, chkshocks', true, @(x) isequal(x, true) || isequal(x, false)
    'chkparam, chkparams, chkparameters', true, @(x) isequal(x, true) || isequal(x, false)
};

opt = passvalopt(defaults, varargin{:});

%--------------------------------------------------------------------------

ixe = this.Quantity.Type==31 | this.Quantity.Type==32;
ixp = this.Quantity.Type==4;

% Incidence of shocks and parameters at shift=0.
ind0 = across(this.Incidence.Dynamic, 'Zero');
ins0 = across(this.Incidence.Steady, 'Zero');
incid = ind0 | ins0;

lsRedShock([ ]) = { };
if opt.chkshock
    incShock = any(incid(:, ixe), 1);
    lsRedShock = this.Quantity.Name(ixe);
    lsRedShock = lsRedShock(~incShock);
end

lsRedParam([ ]) = { };
if opt.chkparam
    incParam = any(incid(:, ixp), 1);
    lsRedParam = this.Quantity.Name(ixp);
    lsRedParam = lsRedParam(~incParam);
end

if opt.warning
    if ~isempty(lsRedShock)
        throw( ...
            exception.Base('Model:REDUNDANT_SHOCK', 'warning'), ...
            lsRedShock{:} ...
            );
    end
    if ~isempty(lsRedParam)
        throw( ...
            exception.Base('Model:REDUNDANT_PARAMETER', 'warning'), ...
            lsRedParam{:} ...
            );
    end
end

end
