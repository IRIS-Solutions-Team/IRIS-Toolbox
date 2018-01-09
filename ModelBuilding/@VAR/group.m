function this = group(this, grp)
% group  Retrieve VAR object from panel VAR for specified group of data.
%
% __Syntax__
%
%     V = group(V, Group)
%
%
% __Input Arguments__
%
% * `V` [ VAR ] - Panel VAR object estimated on multiple groups of data.
%
% * `Group` [ char ] - Requested group name; must be one of the names
% specified when the panel VAR object was constructed using the function
% [`VAR`](VAR/VAR).
%
%
% __Output Arguments__
%
% * `V` [ VAR ] - VAR object for the `K`-th group of data.
%
%
% __Description__
%
%
% __Example__
%
% Create and estimate a panel VAR for three variables, `x`, `y`, `z`, and
% three countries, `US`, `EU`, `JA`. Then, retrieve a plain VAR for an
% individual country.
%
%     v = VAR({'x', 'y', 'z'}, {'US', 'EU', 'JA'});
%     v = estimate(v, d, range, 'fixedEffect=', true);
%     vi_us = group(v, 'US');
%

% -IRIS Macroeconomic Modeling Toolbox.
% -Copyright (c) 2007-2017 IRIS Solutions Team.

pp = inputParser( );
pp.addRequired('V', @(x) isa(x, 'VAR') && ispanel(x));
pp.addRequired('Group', @(x) ischar(x) || isnumericscalar(x) || islogical(x));
pp.parse(this, grp);

%--------------------------------------------------------------------------

if ischar(grp)
    GrpName = grp;
    grp = strcmp(grp, this.GroupNames);
    if ~any(grp)
        utils.error('VAR:group', ...
            'this group does not exist in the %s object: ''%s''.', ...
            class(this), GrpName);
    end
end

if islogical(grp)
    grp = find(grp);
    if length(grp) ~= 1
        utils.error('VAR:group', ...
            'Exactly one group only must be requested.');
    end
end

try
    this.GroupNames = { };
    this.IxFitted = this.IxFitted(grp, :, :);
    this.K = this.K(:, grp, :);
    this.X0 = this.X0(:, grp, :);
    if islogical(grp)
        grp = find(grp);
    end
    nx = length(this.NamesExogenous);
    pos = (grp-1)*nx + (1:nx);
    this.J = this.J(:, pos, :);
    
catch
    utils.error('VAR:group', ...
        'this group does not exist in the %s object: %g.', ...
        class(this), grp);
end

end
