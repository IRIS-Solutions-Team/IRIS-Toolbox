function [lsRedShock, lsRedParam] = chkredundant(this, varargin)
% chkredundant  Check for redundant shocks and/or parameters.
%
%
% Syntax
% =======
%
%     [redShocks, redParams] = chkredundant(m)
%
%
% Input arguments
% ================
%
% * `m` [ model ] - Model object.
%
%
% Output arguments
% =================
%
% * `redShocks` [ cellstr ] - List of shocks that do not occur in any model
% equation.
%
% * `redParams` [ cellstr ] - List of parameters that do not occur in any
% model equation.
%
%
% Options
% ========
%
% * `'Warning='` [ *`true`* | `false` ] - Throw a warning listing redundant
% shocks and parameters.
%
% * `'ChkShocks='` [ *`true`* | `false` ] - Check for redundant shocks.
%
% * `'ChkParams='` [ *`true`* | `false` ] - Check for redundant parameters.
%
%
% Description
% ============
%
%
% Example
% ========
%
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

TYPE = @int8;

opt = passvalopt('model.chkredundant', varargin{:});

%--------------------------------------------------------------------------

ixe = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
ixp = this.Quantity.Type==TYPE(4);

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
