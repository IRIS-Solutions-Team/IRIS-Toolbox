function g = prepareGrouping(this, g, type, opt)
% prepareGrouping  Prepare grouping of specificed type for this model.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2022 IRIS Solutions Team.

add = cell(1, 0);

if startsWith(type, "s", "ignoreCase", true)
    g.Type = 'shock';
    ixType = this.Quantity.Type==31 | this.Quantity.Type==32;
    if opt.IncludeExtras
        add = { ...
            model.CONTRIBUTION_INIT_CONST_DTREND, ...
            model.CONTRIBUTION_NONLINEAR, ...
            };
    end

elseif startsWith(type, "m", "ignoreCase", true)
    g.Type = 'measurement';
    ixType = this.Quantity.Type==1;

end

g.List = [this.Quantity.Name(ixType), add];
g.Label = [this.Quantity.Label(ixType), add];
g.IsLog = access(this, "is-log");

end%

