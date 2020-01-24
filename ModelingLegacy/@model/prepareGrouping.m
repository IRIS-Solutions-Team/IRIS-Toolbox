function g = prepareGrouping(this, g, type, opt)
% prepareGrouping  Prepare grouping of specificed type for this model.
%
% Backend IRIS function.
% No help provided.

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2020 IRIS Solutions Team.

TYPE = @int8;

%--------------------------------------------------------------------------

add = cell(1, 0);

switch lower(type(1))
    case 's'
        g.Type = 'shock';
        ixType = this.Quantity.Type==TYPE(31) | this.Quantity.Type==TYPE(32);
        if opt.IncludeExtras
            add = { ...
                model.CONTRIBUTION_INIT_CONST_DTREND, ...
                model.CONTRIBUTION_NONLINEAR, ...
                };
        end
    case 'm'
        g.Type = 'measurement';
        ixType = this.Quantity.Type==TYPE(1);
end

g.List = [this.Quantity.Name(ixType), add];
g.Label = [this.Quantity.Label(ixType), add];
g.IsLog = implementGet(this, 'IsLog');

end%

